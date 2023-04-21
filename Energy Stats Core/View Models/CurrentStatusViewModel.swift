//
//  CurrentStatusViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

public struct CurrentStatusViewModel: Sendable {
    public let currentSolarPower: Double
    public let currentGridExport: Double
    public let currentHomeConsumption: Double
    public let lastUpdate: Date

    public init(raws: [RawResponse]) {
        currentSolarPower = max(0, raws.currentValue(for: RawVariable.batChargePower) - raws.currentValue(for: RawVariable.batDischargePower) - raws.currentValue(for: RawVariable.gridConsumptionPower) + raws.currentValue(for: RawVariable.loadsPower) + raws.currentValue(for: RawVariable.feedinPower))
        currentGridExport = raws.currentValue(for: RawVariable.feedinPower) - raws.currentValue(for: RawVariable.gridConsumptionPower)
        currentHomeConsumption = raws.currentValue(for: RawVariable.gridConsumptionPower) + raws.currentValue(for: RawVariable.generationPower) - raws.currentValue(for: RawVariable.feedinPower)
        lastUpdate = raws.current(for: .gridConsumptionPower)?.time ?? Date()
    }
}

extension Array where Element == RawResponse {
    func current(for key: RawVariable) -> RawResponse.ReportData? {
        self.first(where: { $0.variable == key.rawValue })?.data.last
    }

    func currentValue(for key: RawVariable) -> Double {
        self.current(for: key)?.value ?? 0.0
    }
}

extension Date {
    public func small() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm:ss"
        return formatter.string(from: self)
    }

    public func iso8601() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}

extension DateFormatter {
    public static func forDebug() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm:ss"
        return formatter
    }
}
