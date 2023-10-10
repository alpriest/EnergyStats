//
//  CurrentStatusCalculator.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

public struct CurrentStatusCalculator: Sendable {
    public let currentSolarPower: Double
    public let currentGrid: Double
    public let currentHomeConsumption: Double
    public let currentTemperatures: InverterTemperatures?
    public let lastUpdate: Date
    public let currentCT2: Double
    static let ACtoDCconversion = 0.92

    public init(device: Device, raws: [RawResponse], shouldInvertCT2: Bool, shouldCombineCT2WithPVPower: Bool) {
        self.currentGrid = raws.currentValue(for: "feedinPower") - raws.currentValue(for: "gridConsumptionPower")
        self.currentHomeConsumption = raws.currentValue(for: "loadsPower") // + raws.currentValue(for: "meterPower2")
        if raws.contains(where: { response in response.variable == "ambientTemperation" }) &&
            raws.contains(where: { response in response.variable == "invTemperation" })
        {
            self.currentTemperatures = InverterTemperatures(ambient: raws.currentValue(for: "ambientTemperation"), inverter: raws.currentValue(for: "invTemperation"))
        } else {
            self.currentTemperatures = nil
        }
        self.lastUpdate = raws.current(for: "gridConsumptionPower")?.time ?? Date()
        self.currentCT2 = ((shouldInvertCT2 ? 0 - raws.currentValue(for: "meterPower2") : raws.currentValue(for: "meterPower2")) / Self.ACtoDCconversion)
        self.currentSolarPower = Self.calculateSolarPower(device: device, raws: raws, shouldInvertCT2: shouldInvertCT2, shouldCombineCT2WithPVPower: shouldCombineCT2WithPVPower)
    }
}

private extension CurrentStatusCalculator {
    static func calculateSolarPower(device: Device, raws: [RawResponse], shouldInvertCT2: Bool, shouldCombineCT2WithPVPower: Bool) -> Double {
        let ct2 = ((shouldInvertCT2 ? 0 - raws.currentValue(for: "meterPower2") : raws.currentValue(for: "meterPower2")) / ACtoDCconversion)

        if device.hasPV {
            return raws.currentValue(for: "pvPower") + (shouldCombineCT2WithPVPower ? ct2 : 0.0)
        } else {
            return ct2
        }
    }
}

extension Array where Element == RawResponse {
    func current(for key: String) -> RawResponse.ReportData? {
        first(where: { $0.variable.lowercased() == key.lowercased() })?.data.last
    }

    func currentValue(for key: String) -> Double {
        current(for: key)?.value ?? 0.0
    }
}

public extension Date {
    func small() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm:ss"
        return formatter.string(from: self)
    }

    func iso8601() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}

public extension DateFormatter {
    static func forDebug() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm:ss"
        return formatter
    }
}
