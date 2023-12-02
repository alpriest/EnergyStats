//
//  ScheduleModels.swift
//  Energy Stats
//
//  Created by Alistair Priest on 29/11/2023.
//

import Energy_Stats_Core
import SwiftUI

struct Schedule {
    let name: String
    let phases: [SchedulePhase]

    init(name: String?, phases: [SchedulePhase]) {
        self.name = name ?? "Schedule"
        self.phases = phases
    }
}

struct SchedulePhase: Identifiable {
    let start: Time
    let end: Time
    let mode: SchedulerModeResponse
    let forceDischargePower: Int
    let forceDischargeSOC: Int
    let batterySOC: Int
    let id = UUID().uuidString
    let color: Color

    init?(start: Time, end: Time, mode: SchedulerModeResponse?, forceDischargePower: Int, forceDischargeSOC: Int, batterySOC: Int, color: Color) {
        guard let mode else { return nil }

        self.start = start
        self.end = end
        self.mode = mode
        self.forceDischargePower = forceDischargePower
        self.forceDischargeSOC = forceDischargeSOC
        self.batterySOC = batterySOC
        self.color = color
    }

    var startPoint: CGFloat { CGFloat(minutesAfterMidnight(start)) / (24 * 60) }
    var endPoint: CGFloat { CGFloat(minutesAfterMidnight(end)) / (24 * 60) }

    private func minutesAfterMidnight(_ time: Time) -> Int {
        (time.hour * 60) + time.minute
    }
}
