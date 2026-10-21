//
//  BatteryResponseMapper.swift
//
//
//  Created by Alistair Priest on 21/10/2026.
//

import Foundation

public enum BatteryResponseMapper {
    public static func map(batteryVariables: OpenQueryResponse, socResponse: BatterySOCResponse, modules: [DeviceBatteryResponse]?) -> Device.Battery? {
        guard let residualData = batteryVariables.datas.current(for: "ResidualEnergy") else { return nil }
        guard let residual = residualData.value else { return nil }

        let batteryCapacity: String
        let minSOC: String

        var unitWh = 10.0
        if let unit = residualData.unit?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if unit.hasSuffix("kWh") {
                let value = unit
                    .replacingOccurrences(of: "kWh", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                unitWh = (Double(value) ?? unitWh) * 1000.0
            } else if unit.hasSuffix("Wh") {
                let value = unit
                    .replacingOccurrences(of: "Wh", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                unitWh = Double(value) ?? unitWh
            }
        }

        let soc = batteryVariables.datas.SoC()
        if soc > 0 {
            batteryCapacity = String(Int((residual * unitWh) / (soc / 100.0)))
        } else {
            batteryCapacity = "0"
        }
        minSOC = String(Double(socResponse.minSocOnGrid) / 100.0)

        let modules = modules?.map { DeviceBatteryModule(batterySN: $0.batterySN, type: $0.type, version: $0.version) }

        return Device.Battery(
            capacity: batteryCapacity,
            minSOC: minSOC,
            modules: modules
        )
    }
}
