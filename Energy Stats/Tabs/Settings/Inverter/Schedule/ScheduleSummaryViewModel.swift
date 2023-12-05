//
//  ScheduleSummaryViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import Foundation

class ScheduleSummaryViewModel: ObservableObject {
    let networking: FoxESSNetworking
    let config: ConfigManaging
    @Published var state: LoadState = .inactive
    @Published var modes: [SchedulerModeResponse] = []
    @Published var templates: [ScheduleTemplateSummary] = []
    @Published var alertContent: AlertContent?
    @Published var schedule: Schedule?
    private var supported: Bool = false

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        self.networking = networking
        self.config = config
    }

    @MainActor
    func preload() async {
        guard
            let deviceSN = config.currentDevice.value?.deviceSN,
            let deviceID = config.currentDevice.value?.deviceID,
            state == .inactive
        else { return }

        self.state = .active(String(key: .loading))

        do {
            self.supported = try await self.networking.fetchSchedulerFlag(deviceSN: deviceSN).support
            if self.supported {
                self.modes = try await self.networking.fetchScheduleModes(deviceID: deviceID)
                self.state = .inactive
            } else {
                self.state = .inactive
                self.alertContent = AlertContent(
                    title: "Not supported",
                    message: "Schedules are not supported on this inverter."
                )
            }
        } catch {
            self.state = LoadState.error(error, error.localizedDescription)
        }
    }

    @MainActor
    func load() async {
        guard
            let deviceSN = config.currentDevice.value?.deviceSN,
            state == .inactive
        else { return }

        if self.modes.count == 0 { await self.preload() }
        setState(.active(String(key: .loading)))

        do {
            let scheduleResponse = try await networking.fetchCurrentSchedule(deviceSN: deviceSN)

            self.templates = scheduleResponse.data.compactMap { $0.toScheduleTemplate() }
            self.schedule = Schedule(name: "", phases: scheduleResponse.pollcy.compactMap { $0.toSchedulePhase(workModes: self.modes) })
            setState(.inactive)
        } catch {
            setState(.error(error, error.localizedDescription))
        }
    }

    @MainActor
    func enable(templateID: String) async {
        guard
            let deviceSN = config.currentDevice.value?.deviceSN,
            state == .inactive
        else { return }

        do {
            self.state = .active(String(key: .saving))

            try await networking.enableScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
            await load()
            setState(.inactive)
        } catch {
            setState(.error(error, error.localizedDescription))
        }
    }

    private func setState(_ state: LoadState) {
        Task { @MainActor in
            self.state = state
        }
    }
}

extension ScheduleTemplateSummaryResponse {
    func toScheduleTemplate() -> ScheduleTemplateSummary? {
        guard !templateID.isEmpty else { return nil }

        return ScheduleTemplateSummary(
            id: templateID,
            name: templateName,
            enabled: enable
        )
    }
}
