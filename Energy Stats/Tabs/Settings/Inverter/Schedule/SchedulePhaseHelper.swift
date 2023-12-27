//
//  SchedulePhaseHelper.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/12/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

enum SchedulePhaseHelper {
    static func addNewTimePeriod(to schedule: Schedule, modes: [SchedulerModeResponse], device: Device?) -> Schedule {
        guard let mode = modes.first else { return schedule }

        return Schedule(
            name: schedule.name,
            phases: schedule.phases + [SchedulePhase(mode: mode, device: device)].sorted { $0.start < $1.start },
            templateID: schedule.templateID
        )
    }

    static func updated(phase updatedPhase: SchedulePhase, on schedule: Schedule) -> Schedule {
        return Schedule(
            name: schedule.name,
            phases: schedule.phases.map {
                if $0.id == updatedPhase.id {
                    return updatedPhase
                } else {
                    return $0
                }
            },
            templateID: schedule.templateID
        )
    }

    static func deleted(phaseID id: String, on schedule: Schedule) -> Schedule {
        return Schedule(
            name: schedule.name,
            phases: schedule.phases.compactMap {
                if $0.id == id {
                    return nil
                } else {
                    return $0
                }
            },
            templateID: schedule.templateID
        )
    }

    static func appendPhasesInGaps(to schedule: Schedule, mode: SchedulerModeResponse, device: Device?) -> Schedule {
        let soc = Int(device?.battery?.minSOC) ?? 10
        let newPhases = schedule.phases + createPhasesInGaps(on: schedule, mode: mode, soc: soc)

        return Schedule(
            name: schedule.name,
            phases: newPhases.sorted { $0.start < $1.start },
            templateID: schedule.templateID
        )
    }

    static func createPhasesInGaps(on schedule: Schedule, mode: SchedulerModeResponse, soc: Int) -> [SchedulePhase] {
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

    private static func makePhase(from start: Time, to end: Time, mode: SchedulerModeResponse, soc: Int) -> SchedulePhase {
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