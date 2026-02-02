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
    case omit

    public func title() -> String {
        switch self {
        case .snapshot:
            String(localized: "power")
        case .total:
            String(localized: "energy")
        case .omit:
            ""
        }
    }
}

public struct Variable: Codable, Equatable, Hashable {
    public let name: String
    public let variable: String
    public let unit: String

    public init(name: String, variable: String, unit: String) {
        self.name = name
        self.variable = variable
        self.unit = unit
    }

    public func copy(
        name: String? = nil,
        variable: String? = nil,
        unit: String? = nil
    ) -> Variable {
        Variable(
            name: name ?? self.name,
            variable: variable ?? self.variable,
            unit: unit ?? self.unit
        )
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.variable == rhs.variable
    }

    public static var solcastPredictionVariable: Variable {
        Variable(name: String(key: .solcastPrediction), variable: "solcast_prediction", unit: "kW")
    }

    public func fuzzyNameMatches(other: String) -> Bool {
        // Systems with multiple batteries can return the raw variable name with a numbering appended
        self.variable == other ||
            other == "\(self.variable)_1" ||
            other == "\(self.variable)_2" ||
            other == "\(self.variable)_3"
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
            return self.name
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
        case Variable.solcastPredictionVariable.variable:
            return .blue
        default:
            if let md5 = self.variable.md5() {
                return Color(hex: String(md5.prefix(6)))
            } else {
                return Color.black
            }
        }
    }

    var description: String? {
        let key = "rawvariable_\(self.variable.lowercased())"
        let localized = NSLocalizedString(key, comment: "")
        if localized.isEmpty || localized == key {
            return nil
        } else {
            return localized
        }
    }
}

public extension Array where Element == Variable {
    func named(_ variable: String) -> Variable? {
        first(where: { $0.variable == variable })
    }
}
