//
//  Schedule.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 03/12/2023.
//

import SwiftUI

//public struct ScheduleTemplateSummary: Identifiable {
//    public let id: String
//    public let name: String
//    public let enabled: Bool
//
//    public init(id: String, name: String, enabled: Bool) {
//        self.id = id
//        self.name = name
//        self.enabled = enabled
//    }
//}
//
//public struct ScheduleTemplate: Identifiable {
//    public let id: String
//    public let phases: [SchedulePhase]
//
//    public init(id: String, phases: [SchedulePhase]) {
//        self.id = id
//        self.phases = phases
//    }
//}

public struct Schedule: Hashable, Equatable {
    public let phases: [SchedulePhase]
//    public let templateID: String?

    public init(phases: [SchedulePhase]) {
        self.phases = phases
//        self.templateID = templateID
    }
}

public struct SchedulePhase: Identifiable, Hashable, Equatable {
    public let id: String
    public let start: Time
    public let end: Time
    public let mode: WorkMode
    public let minSocOnGrid: Int
    public let forceDischargePower: Int
    public let forceDischargeSOC: Int
    public let color: Color

    public init?(id: String? = nil, start: Time, end: Time, mode: WorkMode, minSocOnGrid: Int, forceDischargePower: Int, forceDischargeSOC: Int, color: Color) {
        guard start < end else { return nil }

        self.id = id ?? UUID().uuidString
        self.start = start
        self.end = end
        self.mode = mode
        self.minSocOnGrid = minSocOnGrid
        self.forceDischargePower = forceDischargePower
        self.forceDischargeSOC = forceDischargeSOC
        self.color = color
    }

    public init(mode: WorkMode, device: Device?) {
        self.id = UUID().uuidString
        self.start = Date().toTime()
        self.end = Date().toTime().adding(minutes: 1)
        self.mode = mode
        self.forceDischargePower = 0
        self.forceDischargeSOC = Int(device?.battery?.minSOC) ?? 10
        self.minSocOnGrid = Int(device?.battery?.minSOC) ?? 10
        self.color = Color.scheduleColor(named: mode)
    }

    public var startPoint: CGFloat { CGFloat(minutesAfterMidnight(start)) / (24 * 60) }
    public var endPoint: CGFloat { CGFloat(minutesAfterMidnight(end)) / (24 * 60) }

    private func minutesAfterMidnight(_ time: Time) -> Int {
        (time.hour * 60) + time.minute
    }

    public func isValid() -> Bool {
        end > start
    }
}
