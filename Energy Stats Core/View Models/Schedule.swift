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
    public let phases: [SchedulePhaseV3]

    public init(id: String, name: String, phases: [SchedulePhaseV3]) {
        self.id = id
        self.name = name
        self.phases = phases
    }

    public func asSchedule() -> Schedule {
        Schedule(phases: self.phases)
    }

    public func copy(phases: [SchedulePhaseV3]? = nil, name: String? = nil) -> ScheduleTemplate {
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
            SchedulePhaseV3(
                start: Time(
                    hour: 1,
                    minute: 00
                ),
                end: Time(
                    hour: 2,
                    minute: 00
                ),
                mode: "ForceCharge",
                extraParam: [
                    "minSocOnGrid": 100,
                    "forceDischargePower": 0,
                    "forceDischargeSOC": 100,
                    "maxSOC": 100,
                ]
            ),
            SchedulePhaseV3(
                start: Time(
                    hour: 10,
                    minute: 30
                ),
                end: Time(
                    hour: 14,
                    minute: 30
                ),
                mode: "ForceDischarge",
                extraParam: [
                    "minSocOnGrid": 20,
                    "forceDischargePower": 3500,
                    "forceDischargeSOC": 20,
                    "maxSOC": 100,
                ]
            ),
        ])
    }
}

public struct Schedule: Hashable, Equatable {
    public let phases: [SchedulePhaseV3]

    public init(phases: [SchedulePhaseV3]) {
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

public class FieldDefinitionBuilder {
    private let properties: [String: SchedulePropertyDefinition]
    private let phase: SchedulePhaseV3

    public init(properties: [String: SchedulePropertyDefinition], phase: SchedulePhaseV3) {
        self.properties = properties
        self.phase = phase
    }

    public func make(
        for key: String,
        isStandard: Bool,
        title: String,
        description: LocalizedStringKey?,
        defaultValue: Double?,
    ) -> SchedulePhaseFieldDefinition {
        let property = self.properties[key.lowercased()]

        return SchedulePhaseFieldDefinition(
            key: key,
            isStandard: isStandard,
            title: title,
            precision: property?.precision ?? 0,
            range: property?.range,
            unit: property?.unit,
            value: self.phase.valueFor(key: key.lowercased()) ?? defaultValue,
            description: description
        )
    }
}

public struct SchedulePhaseParameter: Hashable, Equatable, Codable {
    public let precision: Double
    public let range: SchedulePropertyDefinitionRange?
    public let unit: String
}

public struct SchedulePhaseV3: Identifiable, Hashable, Equatable, Codable {
    public let id: String
    public let start: Time
    public let end: Time
    public let mode: WorkMode
    public let extraParam: [String: Double]
    public var startPoint: CGFloat { CGFloat(self.minutesAfterMidnight(self.start)) / (24 * 60) }
    public var endPoint: CGFloat { CGFloat(self.minutesAfterMidnight(self.end)) / (24 * 60) }
    private let color: Color

    private func minutesAfterMidnight(_ time: Time) -> Int {
        (time.hour * 60) + time.minute
    }

    public init(
        id: String? = nil,
        start: Time,
        end: Time,
        mode: WorkMode,
        extraParam: [String: Double]
    ) {
        self.id = id ?? UUID().uuidString
        self.start = start
        self.end = end
        self.mode = mode
        self.extraParam = extraParam
        self.color = Color.scheduleColor(named: mode)
    }

    public func isValid() -> Bool {
        self.end > self.start
    }

    public var displayColor: Color {
        self.color
    }

    public func valueFor(key: String) -> Double? {
        self.extraParam.first { $0.key.lowercased() == key.lowercased() }?.value
    }

    public func stringValueFor(key: String) -> String {
        if let value = valueFor(key: key) {
            String(Int(value))
        } else {
            "??"
        }
    }

    public func copy(
        mode: WorkMode? = nil,
        start: Time? = nil,
        end: Time? = nil,
    ) -> SchedulePhaseV3 {
        SchedulePhaseV3(
            id: self.id,
            start: start ?? self.start,
            end: end ?? self.end,
            mode: mode ?? self.mode,
            extraParam: self.extraParam
        )
    }

    private enum CodingKeys: CodingKey {
        case id
        case start
        case end
        case mode
        case extraParam
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.start = try container.decode(Time.self, forKey: .start)
        self.end = try container.decode(Time.self, forKey: .end)
        self.mode = try container.decode(String.self, forKey: .mode)
        self.extraParam = try container.decodeIfPresent([String: Double].self, forKey: .extraParam) ?? [:]
        self.color = Color.scheduleColor(named: self.mode)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.start, forKey: .start)
        try container.encode(self.end, forKey: .end)
        try container.encode(self.mode, forKey: .mode)
        try container.encode(self.extraParam, forKey: .extraParam)
    }

    public func isEqualConfiguration(to other: SchedulePhaseV3) -> Bool {
        self.start == other.start &&
            self.end == other.end &&
            self.mode == other.mode &&
            self.extraParam == other.extraParam
    }
}

public struct SchedulePhaseFieldDefinition: Copiable {
    public let key: String
    public let isStandard: Bool
    public let title: String
    public let precision: Double
    public let range: SchedulePropertyDefinitionRange?
    public let unit: String?
    public var value: Double?
    public var description: LocalizedStringKey?

    public func create(copying previous: SchedulePhaseFieldDefinition) -> SchedulePhaseFieldDefinition {
        SchedulePhaseFieldDefinition(
            key: previous.key,
            isStandard: previous.isStandard,
            title: previous.title,
            precision: previous.precision,
            range: previous.range,
            unit: previous.unit,
            value: previous.value,
            description: previous.description
        )
    }
}

public extension SchedulePhaseResponse {
    func toSchedulePhase() -> SchedulePhaseV3? {
        return SchedulePhaseV3(
            start: Time(hour: startHour, minute: startMinute),
            end: Time(hour: endHour, minute: endMinute),
            mode: workMode,
            extraParam: extraParam ?? [:]
        )
    }
}
