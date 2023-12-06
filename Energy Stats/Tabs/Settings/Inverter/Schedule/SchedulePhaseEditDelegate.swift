//
//  SchedulePhaseEditDelegate.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/12/2023.
//

import Energy_Stats_Core
import Foundation

enum SchedulePhaseHelper {
    static func addNewTimePeriod(to schedule: Schedule, modes: [SchedulerModeResponse]) -> Schedule {
        guard let mode = modes.first else { return schedule }

        return Schedule(
            name: schedule.name,
            phases: schedule.phases + [SchedulePhase(mode: mode)],
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
}
