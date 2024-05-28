//
//  ReportVariable.swift
//  Energy Stats
//
//  Created by Alistair Priest on 14/11/2022.
//

import SwiftUI

public enum ReportVariable: String, RawRepresentable {
    case feedIn
    case generation
    case gridConsumption
    case chargeEnergyToTal
    case dischargeEnergyToTal
    case loads
    case selfSufficiency

    public var networkTitle: String {
        switch self {
        case .feedIn:
            return "feedin"
        case .chargeEnergyToTal:
            return "chargeEnergyToTal"
        case .dischargeEnergyToTal:
            return "dischargeEnergyToTal"
        default:
            return self.rawValue
        }
    }

    public init?(rawValue: String) {
        switch rawValue {
        case "generation":
            self = .generation
        case "feedin":
            self = .feedIn
        case "gridConsumption":
            self = .gridConsumption
        case "chargeEnergyToTal":
            self = .chargeEnergyToTal
        case "dischargeEnergyToTal":
            self = .dischargeEnergyToTal
        case "loads":
            self = .loads
        default:
            return nil
        }
    }

    public var title: String {
        let usage = ValueUsage.total

        switch self {
        case .generation:
            return String(localized: "Output ") + usage.title()
        case .feedIn:
            return String(localized: "Feed-in ") + usage.title()
        case .chargeEnergyToTal:
            return String(localized: "Charge ") + usage.title()
        case .dischargeEnergyToTal:
            return String(localized: "Discharge ") + usage.title()
        case .gridConsumption:
            return String(localized: "Grid consumption ") + usage.title()
        case .loads:
            return String(localized: "Loads ") + usage.title()
        case .selfSufficiency:
            return String(localized: "Self sufficiency")
        }
    }

    public var description: String {
        switch self {
        case .selfSufficiency:
            return ""
        default:
            let key = "reportvariable_\(self.networkTitle.lowercased())"
            return NSLocalizedString(key, comment: "")
        }
    }

    public var colour: Color {
        switch self {
        case .generation:
            return .orange.opacity(0.7)
        case .feedIn:
            return .purple.opacity(0.8)
        case .chargeEnergyToTal:
            return .green.opacity(0.8)
        case .dischargeEnergyToTal:
            return .blue.opacity(0.8)
        case .gridConsumption:
            return .red.opacity(0.8)
        case .loads:
            return Color("loads_power").opacity(0.8)
        case .selfSufficiency:
            return .black
        }
    }
}
