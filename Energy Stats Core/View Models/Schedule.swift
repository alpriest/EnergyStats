//
//  Schedule.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 03/12/2023.
//

import SwiftUI

public struct ScheduleTemplate: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let phases: [SchedulePhase]

    public init(id: String, name: String, phases: [SchedulePhase]) {
        self.id = id
        self.name = name
        self.phases = phases
    }

    public func asSchedule() -> Schedule {
        Schedule(phases: phases)
    }

    public func copy(phases: [SchedulePhase]) -> ScheduleTemplate {
        ScheduleTemplate(
            id: id,
            name: name,
            phases: phases
        )
    }

    public var isValid: Bool {
        asSchedule().isValid()
    }
}

public extension ScheduleTemplate {
    static func preview() -> ScheduleTemplate {
        ScheduleTemplate(id: "1", name: "Force discharge", phases: [
            SchedulePhase(
                start: Time(
                    hour: 1,
                    minute: 00
                ),
                end: Time(
                    hour: 2,
                    minute: 00
                ),
                mode: .ForceCharge,
                minSocOnGrid: 100,
                forceDischargePower: 0,
                forceDischargeSOC: 100,
                color: .linesNegative
            )!,
            SchedulePhase(
                start: Time(
                    hour: 10,
                    minute: 30
                ),
                end: Time(
                    hour: 14,
                    minute: 30
                ),
                mode: .ForceDischarge,
                minSocOnGrid: 20,
                forceDischargePower: 3500,
                forceDischargeSOC: 20,
                color: .linesPositive
            )!,
        ])
    }
}

public struct Schedule: Hashable, Equatable {
    public let phases: [SchedulePhase]

    public init(phases: [SchedulePhase]) {
        self.phases = phases
    }

    public func isValid() -> Bool {
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
        if mode == .Invalid { return nil }

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
