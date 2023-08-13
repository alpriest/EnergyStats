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
    public let currentTemperatures: InverterTemperatures?
    public let lastUpdate: Date

    public init(raws: [RawResponse]) {
        currentSolarPower = max(0, raws.currentValue(for: "batChargePower") - raws.currentValue(for: "batDischargePower") - raws.currentValue(for: "gridConsumptionPower") + raws.currentValue(for: "loadsPower") + raws.currentValue(for: "feedinPower"))
        currentGridExport = raws.currentValue(for: "feedinPower") - raws.currentValue(for: "gridConsumptionPower")
        currentHomeConsumption = raws.currentValue(for: "gridConsumptionPower") + raws.currentValue(for: "generationPower") - raws.currentValue(for: "feedinPower")
        if raws.contains(where: { response in response.variable == "ambientTemperation" }) &&
            raws.contains(where: { response in response.variable == "invTemperation" }) {
            currentTemperatures = InverterTemperatures(ambient: raws.currentValue(for: "ambientTemperation"), inverter: raws.currentValue(for: "invTemperation"))
        } else {
            currentTemperatures = nil
        }
        lastUpdate = raws.current(for: "gridConsumptionPower")?.time ?? Date()
    }
}

extension Array where Element == RawResponse {
    func current(for key: String) -> RawResponse.ReportData? {
        self.first(where: { $0.variable.lowercased() == key.lowercased() })?.data.last
    }

    func currentValue(for key: String) -> Double {
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
