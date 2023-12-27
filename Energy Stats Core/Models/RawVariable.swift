//
//  RawVariable.swift
//  Energy Stats
//
//  Created by Alistair Priest on 12/09/2022.
//

import SwiftUI

public enum ValueUsage: String {
    case snapshot
    case total

    public func title() -> String {
        switch self {
        case .snapshot:
            return String(localized: "power")
        case .total:
            return String(localized: "energy")
        }
    }
}

public extension Variable {
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
            return String(localized: "Output ") + usage.title()
        case "feedinPower":
            return String(localized: "Feed-in ") + usage.title()
        case "batChargePower":
            return String(localized: "Charge ") + usage.title()
        case "batDischargePower":
            return String(localized: "Discharge ") + usage.title()
        case "gridConsumptionPower":
            return String(localized: "Grid consumption ") + usage.title()
        case "loadsPower":
            return String(localized: "Loads ") + usage.title()
        default:
            return name
        }
    }

    var colour: Color {
        switch self.variable {
        case "batChargePower":
            return .green.opacity(0.8)
        case "batDischargePower":
            return .blue.opacity(0.8)
        case "generationPower":
            return .orange.opacity(0.7)
        case "gridConsumptionPower":
            return .red.opacity(0.8)
        case "feedinPower":
            return .purple.opacity(0.8)
        case "loadsPower":
            return Color("loads_power").opacity(0.2)
        default:
            if let md5 = self.variable.md5() {
                return Color(hex: String(md5.prefix(6)))
            } else {
                return Color.black
            }
        }
    }

    var description: String {
        let key = "rawvariable_\(self.variable.lowercased())"
        let localized = NSLocalizedString(key, comment: "")
        if localized.isEmpty || localized == key {
            return name
        } else {
            return localized
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

public extension Array where Element == Variable {
    func named(_ variable: String) -> Variable? {
        first(where: { $0.variable == variable })
    }
}
