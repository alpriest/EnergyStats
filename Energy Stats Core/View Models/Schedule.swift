//
//  Schedule.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 03/12/2023.
//

import SwiftUI

public struct ScheduleTemplateSummary: Identifiable {
    public let id: String
    public let name: String
    public let enabled: Bool

    public init(id: String, name: String, enabled: Bool) {
        self.id = id
        self.name = name
        self.enabled = enabled
    }
}

public struct ScheduleTemplate: Identifiable {
    public let id: String
    public let phases: [SchedulePhase]

    public init(id: String, phases: [SchedulePhase]) {
        self.id = id
        self.phases = phases
    }
}

public struct Schedule: Hashable, Equatable {
    public let name: String
    public let phases: [SchedulePhase]
    public let templateID: String?

    public init(name: String?, phases: [SchedulePhase], templateID: String? = nil) {
        self.name = name ?? "Schedule"
        self.phases = phases
        self.templateID = templateID
    }
}

public struct SchedulePhase: Identifiable, Hashable, Equatable {
    public let id: String
    public let start: Time
    public let end: Time
    public let mode: SchedulerModeResponse
    public let forceDischargePower: Int
    public let forceDischargeSOC: Int
    public let batterySOC: Int
    public let color: Color

    public init?(id: String? = nil, start: Time, end: Time, mode: SchedulerModeResponse?, forceDischargePower: Int, forceDischargeSOC: Int, batterySOC: Int, color: Color) {
        guard let mode else { return nil }

        self.id = id ?? UUID().uuidString
        self.start = start
        self.end = end
        self.mode = mode
        self.forceDischargePower = forceDischargePower
        self.forceDischargeSOC = forceDischargeSOC
        self.batterySOC = batterySOC
        self.color = color
    }

    public init(mode: SchedulerModeResponse, device: Device?) {
        self.id = UUID().uuidString
        self.start = Date().toTime()
        self.end = Date().toTime()
        self.mode = mode
        self.forceDischargePower = 0
        self.forceDischargeSOC = Int(device?.battery?.minSOC) ?? 10
        self.batterySOC = Int(device?.battery?.minSOC) ?? 10
        self.color = Color.scheduleColor(named: mode.key)
    }

    public var startPoint: CGFloat { CGFloat(minutesAfterMidnight(start)) / (24 * 60) }
    public var endPoint: CGFloat { CGFloat(minutesAfterMidnight(end)) / (24 * 60) }

    private func minutesAfterMidnight(_ time: Time) -> Int {
        (time.hour * 60) + time.minute
    }

    func toPollcy() -> SchedulePollcy {
        SchedulePollcy(
            startH: start.hour,
            startM: start.minute,
            endH: end.hour,
            endM: end.minute,
            fdpwr: forceDischargePower,
            workMode: mode.key,
            fdsoc: forceDischargeSOC,
            minsocongrid: batterySOC
        )
    }

    public func isValid() -> Bool {
        batterySOC <= forceDischargeSOC && end > start
    }
}
