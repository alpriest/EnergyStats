//
//  ScheduleSummaryViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class ScheduleSummaryViewModel: ObservableObject {
    let networking: FoxESSNetworking
    let config: ConfigManaging
    @Published var state: LoadState = .inactive
    @Published var modes: [SchedulerModeResponse] = []
    @Published var templates: [ScheduleTemplateSummary] = []
    @Published var alertContent: AlertContent?
    @Published var schedule: Schedule?

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        self.networking = networking
        self.config = config
    }

    @MainActor
    func preload() async {
        guard
            let device = config.currentDevice.value,
            state == .inactive
        else { return }

        self.state = .active("Loading")

        do {
            let supported = try await networking.openapi_fetchSchedulerFlag(deviceSN: device.deviceSN).support
            if !supported {
                let message = String(key: .schedulesUnsupported, arguments: [device.deviceDisplayName, self.config.firmwareVersions?.manager ?? ""])
                self.state = .error(nil, message)
            } else {
                self.modes = [
                    SchedulerModeResponse(
                        color: "#80F6BD16",
                        name: "Back Up",
                        key: "Backup"
                    ),
                    SchedulerModeResponse(
                        color: "#805B8FF9",
                        name: "Feed-in Priority",
                        key: "Feedin"
                    ),
                    SchedulerModeResponse(
                        color: "#80BBE9FB",
                        name: "Force Charge",
                        key: "ForceCharge"
                    ),
                    SchedulerModeResponse(
                        color: "#8065789B",
                        name: "Force Discharge",
                        key: "ForceDischarge"
                    ),
                    SchedulerModeResponse(
                        color: "#8061DDAA",
                        name: "Self-Use",
                        key: "SelfUse"
                    )
                ]
                self.state = .inactive
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
            let scheduleResponse = try await networking.openapi_fetchCurrentSchedule(deviceSN: deviceSN)

            // TODO: use scheduleResponse.enabled

            self.schedule = Schedule(name: "", phases: scheduleResponse.groups.compactMap { $0.toSchedulePhase(workModes: self.modes) })
            self.setState(.inactive)
        } catch {
            self.setState(.error(error, error.localizedDescription))
        }
    }

    @MainActor
    func activate(templateID: String) async {
//        guard
//            let deviceSN = config.currentDevice.value?.deviceSN,
//            state == .inactive
//        else { return }
//
//        do {
//            self.state = .active("Activating")
//
//            try await self.networking.enableScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
//            await self.load()
//            self.setState(.inactive)
//        } catch {
//            self.setState(.error(error, error.localizedDescription))
//        }
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

extension ScheduleDetailResponse {
    func toSchedulePhase(workModes: [SchedulerModeResponse]) -> SchedulePhase? {
        SchedulePhase(
            start: Time(hour: startHour, minute: startMinute),
            end: Time(hour: endHour, minute: endMinute),
            mode: workMode,
            minSocOnGrid: minSocOnGrid,
            forceDischargePower: fdpwr ?? 0,
            forceDischargeSOC: fdsoc,
            color: Color.scheduleColor(named: workMode)
        )
    }
}
