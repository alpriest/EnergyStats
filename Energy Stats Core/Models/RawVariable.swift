//
//  RawVariable.swift
//  Energy Stats
//
//  Created by Alistair Priest on 12/09/2022.
//

import SwiftUI

public enum ValueUsage: String {
    case snapshot = "power"
    case total = "energy"
}

public extension RawVariable {
    var reportVariable: ReportVariable? {
        switch self.variable {
        case "generationPower":
            return .generation
        case "feedinPower":
            return .feedIn
        case "batChargePower":
            return .chargeEnergyToTal
        case "batDischargePower":
            return .dischargeEnergyToTal
        case "gridConsumptionPower":
            return .gridConsumption
        default:
            return nil
        }
    }

    func title(as usage: ValueUsage) -> String {
        switch self.variable {
        case "generationPower":
            return "Output " + usage.rawValue
        case "feedinPower":
            return "Feed-in " + usage.rawValue
        case "batChargePower":
            return "Charge " + usage.rawValue
        case "batDischargePower":
            return "Discharge " + usage.rawValue
        case "gridConsumptionPower":
            return "Grid consumption " + usage.rawValue
        case "loadsPower":
            return "Loads " + usage.rawValue
        default:
            return name
        }
    }

    var colour: Color {
        switch self.variable {
        case "batChargePower":
            return .green.opacity(0.8)
        case "batDischargePower":
            return .red.opacity(0.5)
        case "generationPower":
            return .yellow.opacity(0.8)
        case "gridConsumptionPower":
            return .red.opacity(0.8)
        case "feedinPower":
            return .mint.opacity(0.8)
        case "loadsPower":
            return .black.opacity(0.2)
        default:
            if let md5 = self.variable.md5() {
                return Color(hex: String(md5.prefix(6)))
            } else {
                return Color.black
            }
        }
    }

    var description: String {
        switch self.variable {
        case "generationPower":
            return "Solar / Battery power coming through the inverter"
        case "feedinPower":
            return "Power being sent to the grid"
        case "batChargePower":
            return "Power charging the battery"
        case "batDischargePower":
            return "Power discharging from the battery"
        case "gridConsumptionPower":
            return "Power coming from the grid"
        case "loadsPower":
            return "Loads power"
        default:
            return name
        }
    }
}

public struct RawVariable: Codable, Equatable, Hashable {
    public let name: String
    public let variable: String
    public let unit: String

    public init(name: String, variable: String, unit: String) {
        self.name = name
        self.variable = variable
        self.unit = unit
    }
}

public extension Array where Element == RawVariable {
    func named(_ variable: String) -> RawVariable? {
        first(where: { $0.variable == variable })
    }
}
