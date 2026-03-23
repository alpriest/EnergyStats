//
//  SchedulePhaseV1.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/03/2026.
//

import SwiftUI

// This is directly serialised for schedule v1 API
public struct SchedulePhaseV1: Identifiable, Hashable, Equatable, Codable {
    public let id: String
    public let enabled: Bool
    public let start: Time
    public let end: Time
    public let mode: WorkMode
    public let minSocOnGrid: Int
    public let forceDischargePower: Int
    public let forceDischargeSOC: Int
    private let color: Color
    public let maxSOC: Int?
    public let pvLimit: Int?
    public let exportLimit: Int?
    public let importLimit: Int?

    public init?(
        id: String? = nil,
        enabled: Bool,
        start: Time,
        end: Time,
        mode: WorkMode,
        minSocOnGrid: Int,
        forceDischargePower: Int,
        forceDischargeSOC: Int,
        maxSOC: Int?,
        color: Color,
        pvLimit: Int?,
        exportLimit: Int?,
        importLimit: Int?
    ) {
        guard start < end else { return nil }
        if mode == "Invalid" { return nil }

        self.id = id ?? UUID().uuidString
        self.enabled = enabled
        self.start = start
        self.end = end
        self.mode = mode
        self.minSocOnGrid = minSocOnGrid
        self.forceDischargePower = forceDischargePower
        self.forceDischargeSOC = forceDischargeSOC
        self.color = color
        self.maxSOC = maxSOC
        self.pvLimit = pvLimit
        self.exportLimit = exportLimit
        self.importLimit = importLimit
    }

    public init(mode: String, device: Device?, initialiseMaxSOC: Bool) {
        self.id = UUID().uuidString
        self.enabled = true
        self.start = Date().toTime()
        self.end = Date().toTime().adding(minutes: 1)
        self.mode = mode
        self.forceDischargePower = Int((device?.capacity ?? 0.0) * 1000.0)
        self.forceDischargeSOC = Int(device?.battery?.minSOC) ?? 10
        self.minSocOnGrid = Int(device?.battery?.minSOC) ?? 10
        self.color = Color.scheduleColor(named: mode)
        self.maxSOC = initialiseMaxSOC ? 100 : nil
        self.pvLimit = nil
        self.exportLimit = nil
        self.importLimit = nil
    }

    public func copy(
        enabled: Bool,
    ) -> SchedulePhaseV1 {
        SchedulePhaseV1(
            id: self.id,
            enabled: enabled,
            start: self.start,
            end: self.end,
            mode: self.mode,
            minSocOnGrid: self.minSocOnGrid,
            forceDischargePower: self.forceDischargePower,
            forceDischargeSOC: self.forceDischargeSOC,
            maxSOC: self.maxSOC,
            color: self.color,
            pvLimit: self.pvLimit,
            exportLimit: self.exportLimit,
            importLimit: self.importLimit
        )!
    }

    private enum CodingKeys: CodingKey {
        case id
        case enabled
        case start
        case end
        case mode
        case minSocOnGrid
        case forceDischargePower
        case forceDischargeSOC
        case color
        case maxSOC
        case pvLimit
        case exportLimit
        case importLimit
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled) ?? true
        self.start = try container.decode(Time.self, forKey: .start)
        self.end = try container.decode(Time.self, forKey: .end)
        // Migrate users from UNUSED_WorkMode to String -- written Nov 2025
        if let mode = try? container.decode(UNUSED_WorkMode.self, forKey: .mode) {
            self.mode = mode.networkTitle
        } else {
            self.mode = try container.decode(String.self, forKey: .mode)
        }
        self.minSocOnGrid = try container.decode(Int.self, forKey: .minSocOnGrid)
        self.forceDischargePower = try container.decode(Int.self, forKey: .forceDischargePower)
        self.forceDischargeSOC = try container.decode(Int.self, forKey: .forceDischargeSOC)
        self.maxSOC = try? container.decode(Int?.self, forKey: .maxSOC)
        self.color = Color.scheduleColor(named: self.mode)
        self.pvLimit = try? container.decode(Int?.self, forKey: .pvLimit)
        self.exportLimit = try? container.decode(Int?.self, forKey: .exportLimit)
        self.importLimit = try? container.decode(Int?.self, forKey: .importLimit)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.enabled, forKey: .enabled)
        try container.encode(self.start, forKey: .start)
        try container.encode(self.end, forKey: .end)
        try container.encode(self.mode, forKey: .mode)
        try container.encode(self.minSocOnGrid, forKey: .minSocOnGrid)
        try container.encode(self.forceDischargePower, forKey: .forceDischargePower)
        try container.encode(self.forceDischargeSOC, forKey: .forceDischargeSOC)
        try container.encode(self.maxSOC, forKey: .maxSOC)
        try container.encode(self.pvLimit, forKey: .pvLimit)
        try container.encode(self.exportLimit, forKey: .exportLimit)
        try container.encode(self.importLimit, forKey: .importLimit)
    }

    public var startPoint: CGFloat { CGFloat(self.minutesAfterMidnight(self.start)) / (24 * 60) }
    public var endPoint: CGFloat { CGFloat(self.minutesAfterMidnight(self.end)) / (24 * 60) }

    private func minutesAfterMidnight(_ time: Time) -> Int {
        (time.hour * 60) + time.minute
    }

    public func isValid() -> Bool {
        self.end > self.start
    }

    public var displayColor: Color {
        self.color
    }

    func isAllDaySynthesized() -> Bool {
        self.start.hour == 0 && self.start.minute == 0 && self.end.hour == 23 && self.end.minute == 59
    }

    public func isEqualConfiguration(to other: SchedulePhaseV1) -> Bool {
        self.enabled == other.enabled &&
            self.start == other.start &&
            self.end == other.end &&
            self.mode == other.mode &&
            self.minSocOnGrid == other.minSocOnGrid &&
            self.forceDischargePower == other.forceDischargePower &&
            self.forceDischargeSOC == other.forceDischargeSOC &&
            self.maxSOC == other.maxSOC
    }
}
