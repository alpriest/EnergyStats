//
//  Schedule.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 03/12/2023.
//

import SwiftUI

public struct ScheduleTemplate: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let phases: [SchedulePhase]

    public init(id: String, name: String, phases: [SchedulePhase]) {
        self.id = id
        self.name = name
        self.phases = phases
    }

    public func asSchedule() -> Schedule {
        Schedule(phases: self.phases)
    }

    public func copy(phases: [SchedulePhase]? = nil, name: String? = nil) -> ScheduleTemplate {
        ScheduleTemplate(
            id: self.id,
            name: name ?? self.name,
            phases: phases ?? self.phases
        )
    }

    public var isValid: Bool {
        self.asSchedule().isValid()
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
                maxSOC: 100,
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
                maxSOC: 100,
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
        for (index, phase) in self.phases.enumerated() {
            let phaseStart = phase.start.toMinutes()
            let phaseEnd = phase.end.toMinutes()

            // Check for overlap with other phases
            for otherPhase in self.phases[(index + 1)...] {
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

    public static let maxPhasesCount = 8

    public var hasTooManyPhases: Bool {
        self.phases.count > Schedule.maxPhasesCount
    }
}

public struct SchedulePhase: Identifiable, Hashable, Equatable, Codable {
    public let id: String
    public let start: Time
    public let end: Time
    public let mode: WorkMode
    public let minSocOnGrid: Int
    public let forceDischargePower: Int
    public let forceDischargeSOC: Int
    public let color: Color
    public let maxSOC: Int?

    public init?(
        id: String? = nil,
        start: Time,
        end: Time,
        mode: WorkMode,
        minSocOnGrid: Int,
        forceDischargePower: Int,
        forceDischargeSOC: Int,
        maxSOC: Int?,
        color: Color
    ) {
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
        self.maxSOC = maxSOC
    }

    public init(mode: WorkMode, device: Device?, initialiseMaxSOC: Bool) {
        self.id = UUID().uuidString
        self.start = Date().toTime()
        self.end = Date().toTime().adding(minutes: 1)
        self.mode = mode
        self.forceDischargePower = 0
        self.forceDischargeSOC = Int(device?.battery?.minSOC) ?? 10
        self.minSocOnGrid = Int(device?.battery?.minSOC) ?? 10
        self.color = Color.scheduleColor(named: mode)
        self.maxSOC = initialiseMaxSOC ? 100 : nil
    }

    private enum CodingKeys: CodingKey {
        case id
        case start
        case end
        case mode
        case minSocOnGrid
        case forceDischargePower
        case forceDischargeSOC
        case color
        case maxSOC
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.start = try container.decode(Time.self, forKey: .start)
        self.end = try container.decode(Time.self, forKey: .end)
        self.mode = try container.decode(WorkMode.self, forKey: .mode)
        self.minSocOnGrid = try container.decode(Int.self, forKey: .minSocOnGrid)
        self.forceDischargePower = try container.decode(Int.self, forKey: .forceDischargePower)
        self.forceDischargeSOC = try container.decode(Int.self, forKey: .forceDischargeSOC)
        self.maxSOC = try? container.decode(Int?.self, forKey: .maxSOC)
        self.color = Color.scheduleColor(named: self.mode)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.start, forKey: .start)
        try container.encode(self.end, forKey: .end)
        try container.encode(self.mode, forKey: .mode)
        try container.encode(self.minSocOnGrid, forKey: .minSocOnGrid)
        try container.encode(self.forceDischargePower, forKey: .forceDischargePower)
        try container.encode(self.forceDischargeSOC, forKey: .forceDischargeSOC)
        try container.encode(self.maxSOC, forKey: .maxSOC)
    }

    public var startPoint: CGFloat { CGFloat(self.minutesAfterMidnight(self.start)) / (24 * 60) }
    public var endPoint: CGFloat { CGFloat(self.minutesAfterMidnight(self.end)) / (24 * 60) }

    private func minutesAfterMidnight(_ time: Time) -> Int {
        (time.hour * 60) + time.minute
    }

    public func isValid() -> Bool {
        self.end > self.start
    }

    public func isEqualConfiguration(to other: SchedulePhase) -> Bool {
        self.start == other.start &&
            self.end == other.end &&
            self.mode == other.mode &&
            self.minSocOnGrid == other.minSocOnGrid &&
            self.forceDischargePower == other.forceDischargePower &&
            self.forceDischargeSOC == other.forceDischargeSOC &&
            self.maxSOC == other.maxSOC
    }
}
