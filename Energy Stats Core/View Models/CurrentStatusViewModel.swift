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

    public init(device: Device, raws: [RawResponse]) {
        self.currentGridExport = raws.currentValue(for: "feedinPower") - raws.currentValue(for: "gridConsumptionPower")
        self.currentHomeConsumption = raws.currentValue(for: "loadsPower") // + raws.currentValue(for: "meterPower2")
        if raws.contains(where: { response in response.variable == "ambientTemperation" }) &&
            raws.contains(where: { response in response.variable == "invTemperation" })
        {
            self.currentTemperatures = InverterTemperatures(ambient: raws.currentValue(for: "ambientTemperation"), inverter: raws.currentValue(for: "invTemperation"))
        } else {
            self.currentTemperatures = nil
        }
        self.lastUpdate = raws.first?.data.first?.time ?? Date()
        self.currentSolarPower = Self.calculateSolarPower(device: device, raws: raws)
    }
}

private extension CurrentStatusViewModel {
    static func calculateSolarPower(device: Device, raws: [RawResponse]) -> Double {
        if device.hasPV {
            return raws.currentValue(for: "pvPower")
        } else {
            let ACtoDCconversion = 0.92
            return raws.currentValue(for: "meterPower2") / ACtoDCconversion
        }
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
