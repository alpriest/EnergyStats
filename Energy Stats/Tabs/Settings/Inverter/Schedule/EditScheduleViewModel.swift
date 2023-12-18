//
//  ScheduleViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/11/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class EditScheduleViewModel: ObservableObject {
    @Published var schedule: Schedule
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?
    @Published var modes: [SchedulerModeResponse] = []
    private let networking: FoxESSNetworking
    private let config: ConfigManaging

    init(networking: FoxESSNetworking, config: ConfigManaging, schedule: Schedule, modes: [SchedulerModeResponse]) {
        self.networking = networking
        self.config = config
        self.schedule = schedule
        self.modes = modes
    }

    func saveSchedule(onCompletion: @escaping () -> Void) async {
        guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
        guard schedule.isValid() else {
            alertContent = AlertContent(title: "error_title", message: "overlapping_time_periods")
            return
        }

        setState(.active("Activating"))

        Task { [self] in
            do {
                try await networking.saveSchedule(deviceSN: deviceSN, schedule: schedule)

                Task { @MainActor in
                    self.state = .inactive
                    alertContent = AlertContent(
                        title: "Success",
                        message: "inverter_charge_schedule_settings_saved",
                        onDismiss: onCompletion
                    )
                }
            } catch {
                self.state = .inactive
                alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: error.localizedDescription))
            }
        }
    }

    func deleteSchedule(onCompletion: @escaping () -> Void) {
        guard let deviceSN = config.currentDevice.value?.deviceSN else { return }

        setState(.active("Saving"))

        Task { [self] in
            do {
                try await networking.deleteSchedule(deviceSN: deviceSN)

                Task { @MainActor in
                    self.state = .inactive
                    alertContent = AlertContent(
                        title: "Success",
                        message: "inverter_charge_schedule_deleted",
                        onDismiss: onCompletion
                    )
                }
            } catch {
                self.state = .inactive
                alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: error.localizedDescription))
            }
        }
    }

    func autoFillScheduleGaps() {
        guard let mode = modes.first else { return }

        self.schedule = SchedulePhaseHelper.appendPhasesInGaps(to: schedule, mode: mode, device: config.currentDevice.value)
    }

    func addNewTimePeriod() {
        self.schedule = SchedulePhaseHelper.addNewTimePeriod(to: schedule, modes: modes, device: config.currentDevice.value)
    }

    func updatedPhase(_ phase: SchedulePhase) {
        self.schedule = SchedulePhaseHelper.updated(phase: phase, on: schedule)
    }

    func deletedPhase(_ id: String) {
        self.schedule = SchedulePhaseHelper.deleted(phaseID: id, on: schedule)
    }

    private func setState(_ state: LoadState) {
        Task { @MainActor in
            self.state = state
        }
    }

    func unused() {}
}

extension Schedule {
    func isValid() -> Bool {
        for (index, phase) in phases.enumerated() {
            let phaseStart = phase.start.toMinutes()
            let phaseEnd = phase.end.toMinutes()

            // Check for overlap with other phases
            for otherPhase in phases[(index + 1)...] {
                let otherStart = otherPhase.start.toMinutes()
                let otherEnd = otherPhase.end.toMinutes()

                // Check if the time periods overlap
                // Updated to ensure periods must start/end on different minutes
                if phaseStart <= otherEnd && otherStart < phaseEnd {
                    return false
                }

                if !phase.isValid() {
                    return false
                }
            }
        }

        return true
    }
}

extension SchedulePollcy {
    func toSchedulePhase(workModes: [SchedulerModeResponse]) -> SchedulePhase? {
        SchedulePhase(
            start: Time(hour: startH, minute: startM),
            end: Time(hour: endH, minute: endM),
            mode: workModes.first { $0.key == workMode },
            forceDischargePower: fdpwr ?? 0,
            forceDischargeSOC: fdsoc,
            batterySOC: minsocongrid,
            color: Color.scheduleColor(named: workMode)
        )
    }
}

private extension Schedule {
    init(schedule: ScheduleListResponse, workModes: [SchedulerModeResponse]) {
        let phases = schedule.pollcy.compactMap { $0.toSchedulePhase(workModes: workModes) }

        self.init(
            name: nil,
            phases: phases
        )
    }
}
