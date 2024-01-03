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
    private let requiredManagerFirmwareVersion = "1.70"

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        self.networking = networking
        self.config = config
    }

    @MainActor
    func preload() async {
        guard
            let deviceID = config.currentDevice.value?.deviceID,
            state == .inactive
        else { return }

        self.state = .active("Loading")

        do {
            if self.config.firmwareVersions.hasManager(greaterThan: self.requiredManagerFirmwareVersion) {
                self.modes = try await self.networking.fetchScheduleModes(deviceID: deviceID)
                self.state = .inactive
            } else {
                let message = String(key: .schedulesUnsupported, arguments: [self.config.firmwareVersions?.manager ?? "", self.requiredManagerFirmwareVersion])
                self.state = .error(nil, message)
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

        if self.modes.count == 0 {
            await self.preload()
            if case .error = self.state {
                return
            }
        }
        self.state = .active("Loading")

        do {
            let scheduleResponse = try await networking.fetchCurrentSchedule(deviceSN: deviceSN)

            self.templates = scheduleResponse.data.compactMap { $0.toScheduleTemplate() }
            self.schedule = Schedule(name: "", phases: scheduleResponse.pollcy.compactMap { $0.toSchedulePhase(workModes: self.modes) })
            self.setState(.inactive)
        } catch {
            self.setState(.error(error, error.localizedDescription))
        }
    }

    @MainActor
    func activate(templateID: String) async {
        guard
            let deviceSN = config.currentDevice.value?.deviceSN,
            state == .inactive
        else { return }

        do {
            self.state = .active("Activating")

            try await self.networking.enableScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
            await self.load()
            self.setState(.inactive)
        } catch {
            self.setState(.error(error, error.localizedDescription))
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
