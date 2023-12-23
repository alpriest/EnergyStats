//
//  CurrentStatusCalculator.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

#if OPEN_API
public enum RealQueryResponseMapper {
    public static func map(device: Device, responses: [RealQueryResponse]) -> CurrentValues {
        guard let real = responses.first(where: { $0.deviceSN == device.deviceSN }) else { return CurrentValues.empty() }

        return CurrentValues(
            pvPower: real.datas.currentValue(for: "pvPower"),
            feedinPower: real.datas.currentValue(for: "feedinPower"),
            gridConsumptionPower: real.datas.currentValue(for: "gridConsumptionPower"),
            loadsPower: real.datas.currentValue(for: "loadsPower"),
            ambientTemperation: real.datas.currentValue(for: "ambientTemperation"),
            invTemperation: real.datas.currentValue(for: "invTemperation"),
            meterPower2: real.datas.currentValue(for: "meterPower2"),
            hasPV: device.hasPV,
            lastUpdate: real.time
        )
    }
}

extension Array where Element == RealQueryResponse.RealData {
    func current(for key: String) -> Double? {
        first(where: { $0.variable.lowercased() == key.lowercased() })?.value
    }

    func currentValue(for key: String) -> Double {
        current(for: key) ?? 0.0
    }
}

#endif

public enum RawResponseMapper {
    public static func map(device: Device, raws: [RawResponse]) -> CurrentValues {
        CurrentValues(
            pvPower: raws.currentValue(for: "pvPower"),
            feedinPower: raws.currentValue(for: "feedinPower"),
            gridConsumptionPower: raws.currentValue(for: "gridConsumptionPower"),
            loadsPower: raws.currentValue(for: "loadsPower"),
            ambientTemperation: raws.currentValue(for: "ambientTemperation"),
            invTemperation: raws.currentValue(for: "invTemperation"),
            meterPower2: raws.currentValue(for: "meterPower2"),
            hasPV: device.hasPV,
            lastUpdate: raws.current(for: "gridConsumptionPower")?.time ?? Date()
        )
    }
}

public struct CurrentValues {
    let pvPower: Double
    let feedinPower: Double
    let gridConsumptionPower: Double
    let loadsPower: Double
    let ambientTemperation: Double
    let invTemperation: Double
    let meterPower2: Double
    let hasPV: Bool
    let lastUpdate: Date

    static func empty() -> CurrentValues {
        .init(pvPower: 0, feedinPower: 0, gridConsumptionPower: 0, loadsPower: 0, ambientTemperation: 0, invTemperation: 0, meterPower2: 0, hasPV: false, lastUpdate: Date())
    }
}

public struct CurrentStatusCalculator: Sendable {
    public let currentSolarPower: Double
    public let currentGrid: Double
    public let currentHomeConsumption: Double
    public let currentTemperatures: InverterTemperatures?
    public let lastUpdate: Date
    public let currentCT2: Double

    public init(status: CurrentValues, shouldInvertCT2: Bool, shouldCombineCT2WithPVPower: Bool) {
        self.currentGrid = status.feedinPower - status.gridConsumptionPower
        self.currentHomeConsumption = status.loadsPower // + raws.currentValue(for: "meterPower2")
        self.currentTemperatures = InverterTemperatures(ambient: status.ambientTemperation, inverter: status.invTemperation)
        self.lastUpdate = status.lastUpdate
        self.currentCT2 = shouldInvertCT2 ? 0 - status.meterPower2 : status.meterPower2
        self.currentSolarPower = Self.calculateSolarPower(hasPV: status.hasPV, status: status, shouldInvertCT2: shouldInvertCT2, shouldCombineCT2WithPVPower: shouldCombineCT2WithPVPower)
    }
}

private extension CurrentStatusCalculator {
    static func calculateSolarPower(hasPV: Bool, status: CurrentValues, shouldInvertCT2: Bool, shouldCombineCT2WithPVPower: Bool) -> Double {
        let ct2 = (shouldInvertCT2 ? 0 - status.meterPower2 : status.meterPower2)

        if hasPV {
            return status.pvPower + (shouldCombineCT2WithPVPower ? ct2 : 0.0)
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
