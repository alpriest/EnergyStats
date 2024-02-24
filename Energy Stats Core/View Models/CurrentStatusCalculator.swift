//
//  CurrentStatusCalculator.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

public extension Array where Element == OpenQueryResponse.Data {
    func current(for key: String) -> Double? {
        first(where: { $0.variable.lowercased() == key.lowercased() })?.value
    }

    func currentValue(for key: String) -> Double {
        current(for: key) ?? 0.0
    }
}

public struct CurrentStatusCalculator: Sendable {
    public let currentSolarPower: Double
    public let currentSolarStringsPower: [Double]
    public let currentGrid: Double
    public let currentHomeConsumption: Double
    public let currentTemperatures: InverterTemperatures?
    public let lastUpdate: Date
    public let currentCT2: Double

    public init(device: Device, response: OpenQueryResponse, shouldInvertCT2: Bool, shouldCombineCT2WithPVPower: Bool, shouldCombineCT2WithLoadsPower: Bool) {
        let status = Self.mapCurrentValues(device: device, response: response)

        self.currentGrid = status.feedinPower - status.gridConsumptionPower
        self.currentHomeConsumption = Self.calculateLoadPower(status: status, shouldCombineCT2WithLoadsPower: shouldCombineCT2WithLoadsPower)
        self.currentTemperatures = InverterTemperatures(ambient: status.ambientTemperation, inverter: status.invTemperation)
        self.lastUpdate = status.lastUpdate
        self.currentCT2 = shouldInvertCT2 ? 0 - status.meterPower2 : status.meterPower2
        self.currentSolarPower = Self.calculateSolarPower(hasPV: status.hasPV, status: status, shouldInvertCT2: shouldInvertCT2, shouldCombineCT2WithPVPower: shouldCombineCT2WithPVPower)
        self.currentSolarStringsPower = Self.calculateSolarStringsPower(hasPV: status.hasPV, status: status, shouldInvertCT2: shouldInvertCT2, shouldCombineCT2WithPVPower: shouldCombineCT2WithPVPower)
    }

    static func mapCurrentValues(device: Device, response: OpenQueryResponse) -> CurrentRawValues {
        CurrentRawValues(
            pvPower: response.datas.currentValue(for: "pvPower"),
            stringsPvPower: [response.datas.currentValue(for: "pv1Power"), response.datas.currentValue(for: "pv2Power")],
            feedinPower: response.datas.currentValue(for: "feedinPower"),
            gridConsumptionPower: response.datas.currentValue(for: "gridConsumptionPower"),
            loadsPower: response.datas.currentValue(for: "loadsPower"),
            ambientTemperation: response.datas.currentValue(for: "ambientTemperation"),
            invTemperation: response.datas.currentValue(for: "invTemperation"),
            meterPower2: response.datas.currentValue(for: "meterPower2"),
            hasPV: device.hasPV,
            lastUpdate: response.time
        )
    }

    static func calculateLoadPower(status: CurrentRawValues, shouldCombineCT2WithLoadsPower: Bool) -> Double {
        max(0, status.loadsPower + (shouldCombineCT2WithLoadsPower ? status.meterPower2 : 0.0))
    }

    static func calculateSolarPower(hasPV: Bool, status: CurrentRawValues, shouldInvertCT2: Bool, shouldCombineCT2WithPVPower: Bool) -> Double {
        let ct2 = (shouldInvertCT2 ? 0 - status.meterPower2 : status.meterPower2)

        if hasPV {
            return status.pvPower + (shouldCombineCT2WithPVPower ? ct2 : 0.0)
        } else {
            return ct2
        }
    }

    static func calculateSolarStringsPower(hasPV: Bool, status: CurrentRawValues, shouldInvertCT2: Bool, shouldCombineCT2WithPVPower: Bool) -> [Double] {
        let ct2 = (shouldInvertCT2 ? 0 - status.meterPower2 : status.meterPower2)

        if hasPV {
            return status.stringsPvPower.map { $0 + (shouldCombineCT2WithPVPower ? ct2 : 0.0) }
        } else {
            return [ct2]
        }
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

public struct CurrentRawValues {
    let pvPower: Double
    let stringsPvPower: [Double]
    let feedinPower: Double
    let gridConsumptionPower: Double
    let loadsPower: Double
    let ambientTemperation: Double
    let invTemperation: Double
    let meterPower2: Double
    let hasPV: Bool
    let lastUpdate: Date

    static func empty() -> CurrentRawValues {
        .init(pvPower: 2, stringsPvPower: [], feedinPower: 0, gridConsumptionPower: 0, loadsPower: 0, ambientTemperation: 0, invTemperation: 0, meterPower2: 0, hasPV: false, lastUpdate: Date())
    }
}
