//
//  ScheduleViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/11/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class ScheduleViewModel: ObservableObject {
    @Published var schedule: Schedule
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?
    @Published var modes: [SchedulerModeResponse] = []

    init(schedule: Schedule, modes: [SchedulerModeResponse]) {
        self.schedule = schedule
        self.modes = modes
    }

    func load() {
//        Task { @MainActor [self] in
//            guard
//                let deviceSN = config.currentDevice.value?.deviceSN,
//                let deviceID = config.currentDevice.value?.deviceID
//            else { return }
//            guard schedule == nil else { return }
//
//            self.state = .active(String(key: .loading))
//
//            do {
//                let flag = try await networking.fetchSchedulerFlag(deviceSN: deviceSN)
//                if flag.support {
//                    self.modes = try await networking.fetchScheduleModes(deviceID: deviceID)
//                    let scheduleResponse = try await networking.fetchSchedule(deviceSN: deviceSN)
//
//                    self.schedule = Schedule(schedule: scheduleResponse, workModes: self.modes)
//                    self.enabled = scheduleResponse.enable
//                    self.state = .inactive
//                } else {
//                    self.state = .inactive
//                    alertContent = AlertContent(
//                        title: "Not supported",
//                        message: "Schedules are not supported on this inverter."
//                    )
//                }
//            } catch {
//                self.state = LoadState.error(error, error.localizedDescription)
//            }
//        }
    }

//    func save() {
//        guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
//        guard let schedule else {
//            alertContent = AlertContent(title: "error_title", message: "No schedule to save.")
//            return
//        }
//        guard isValid() else {
//            alertContent = AlertContent(title: "error_title", message: "overlapping_time_periods")
//            return
//        }
//
//        Task { @MainActor [self] in
//            do {
//                self.state = .active(String(key: .saving))
//                try await networking.saveSchedule(deviceSN: deviceSN, schedule: schedule)
//                self.state = .inactive
//                alertContent = AlertContent(
//                    title: "Success",
//                    message: "inverter_charge_schedule_settings_saved"
//                )
//            } catch {
//                self.state = .inactive
//                alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: error.localizedDescription))
//            }
//        }
//    }

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

//    func addNewTimePeriod() {
//        guard let schedule else { return }
//        guard let mode = modes.first else { return }
//
//        self.schedule = Schedule(
//            name: schedule.name,
//            phases: schedule.phases + [SchedulePhase(mode: mode)]
//        )
//    }

//    func updated(phase updatedPhase: SchedulePhase) {
//        guard let schedule else { return }
//
//        self.schedule = Schedule(
//            name: schedule.name,
//            phases: schedule.phases.map {
//                if $0.id == updatedPhase.id {
//                    return updatedPhase
//                } else {
//                    return $0
//                }
//            }
//        )
//    }

//    func deleted(id: String) {
//        guard let schedule else { return }
//
//        self.schedule = Schedule(
//            name: schedule.name,
//            phases: schedule.phases.compactMap {
//                if $0.id == id {
//                    return nil
//                } else {
//                    return $0
//                }
//            }
//        )
//    }
}

extension ScheduleViewModel {
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

    @MainActor
    func appendPhasesInGaps(mode: SchedulerModeResponse, soc: Int) {
        let newPhases = schedule.phases + createPhasesInGaps(mode: mode, soc: soc)

        schedule = Schedule(
            name: schedule.name,
            phases: newPhases.sorted { $0.start < $1.start }
        )
    }

    func createPhasesInGaps(mode: SchedulerModeResponse, soc: Int) -> [SchedulePhase] {
        // Ensure the phases are sorted by start time
        let sortedPhases = schedule.phases.sorted { $0.start < $1.start }

        let scheduleStartTime = Time(hour: 00, minute: 00)
        let scheduleEndTime = Time(hour: 23, minute: 59)
        var newPhases = [SchedulePhase]()
        var lastEnd: Time?

        for phase in sortedPhases {
            if let lastEnd {
                if lastEnd < phase.start.adding(minutes: -1) {
                    let newPhaseStart = lastEnd.adding(minutes: 1)
                    let newPhaseEnd = phase.start.adding(minutes: -1)

                    // There's a gap between lastEnd and the current phase's start
                    let newPhase = makePhase(from: newPhaseStart, to: newPhaseEnd, mode: mode, soc: soc)
                    newPhases.append(newPhase)
                }
            } else {
                if phase.start > scheduleStartTime {
                    // There's a gap between startOfDay and the current phase's start
                    let newPhaseEnd = phase.start.adding(minutes: -1)

                    let newPhase = makePhase(from: scheduleStartTime, to: newPhaseEnd, mode: mode, soc: soc)
                    newPhases.append(newPhase)
                }
            }
            lastEnd = phase.end
        }

        // Check if there's a gap after the last phase
        if let lastEnd = lastEnd, lastEnd < Time(hour: 23, minute: 59) {
            let finalPhaseStart = lastEnd.adding(minutes: 1)
            let finalPhase = makePhase(from: finalPhaseStart, to: scheduleEndTime, mode: mode, soc: soc)
            newPhases.append(finalPhase)
        }

        return newPhases
    }

    private func makePhase(from start: Time, to end: Time, mode: SchedulerModeResponse, soc: Int) -> SchedulePhase {
        SchedulePhase(
            start: start,
            end: end,
            mode: mode,
            forceDischargePower: 0,
            forceDischargeSOC: soc,
            batterySOC: soc,
            color: Color.scheduleColor(named: mode.key)
        )!
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
