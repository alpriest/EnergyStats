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

    func applyCurrentSchedule() {
        guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
        guard isValid() else {
            alertContent = AlertContent(title: "error_title", message: "overlapping_time_periods")
            return
        }

        Task { @MainActor [self] in
            do {
                self.state = .active(String(key: .saving))
                try await networking.saveSchedule(deviceSN: deviceSN, schedule: schedule)
                self.state = .inactive
                alertContent = AlertContent(
                    title: "Success",
                    message: "inverter_charge_schedule_settings_saved"
                )
            } catch {
                self.state = .inactive
                alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: error.localizedDescription))
            }
        }
    }

//    func deleteSchedule() {
//        guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
//
//        Task { @MainActor [self] in
//            self.state = .active(String(key: .saving))
//            do {
//                try await networking.deleteSchedule(deviceSN: deviceSN)
//                self.state = .inactive
//                alertContent = AlertContent(
//                    title: "Success",
//                    message: "inverter_charge_schedule_deleted"
//                )
//            } catch {
//                self.state = .inactive
//                alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: error.localizedDescription))
//            }
//        }
//    }

    func addNewTimePeriod() {
        guard let mode = modes.first else { return }

        self.schedule = Schedule(
            name: schedule.name,
            phases: schedule.phases + [SchedulePhase(mode: mode)]
        )
    }

    func updated(phase updatedPhase: SchedulePhase) {
        self.schedule = Schedule(
            name: schedule.name,
            phases: schedule.phases.map {
                if $0.id == updatedPhase.id {
                    return updatedPhase
                } else {
                    return $0
                }
            }
        )
    }

    func deleted(phase id: String) {
        self.schedule = Schedule(
            name: schedule.name,
            phases: schedule.phases.compactMap {
                if $0.id == id {
                    return nil
                } else {
                    return $0
                }
            }
        )
    }
}

extension EditScheduleViewModel {
    func isValid() -> Bool {
        for (index, phase) in schedule.phases.enumerated() {
            let phaseStart = phase.start.toMinutes()
            let phaseEnd = phase.end.toMinutes()

            // Check for overlap with other phases
            for otherPhase in schedule.phases[(index + 1)...] {
                let otherStart = otherPhase.start.toMinutes()
                let otherEnd = otherPhase.end.toMinutes()

                // Check if the time periods overlap
                // Updated to ensure periods must start/end on different minutes
                if phaseStart <= otherEnd && otherStart < phaseEnd {
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
            forceDischargePower: fdpwr,
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
