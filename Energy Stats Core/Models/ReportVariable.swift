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
        }
    }

    public var description: String {
        switch self {
        case .generation:
            return String(localized: "Solar / Battery power coming through the inverter")
        case .feedIn:
            return String(localized: "Power being sent to the grid")
        case .chargeEnergyToTal:
            return String(localized: "Power charging the battery")
        case .dischargeEnergyToTal:
            return String(localized: "Power discharging from the battery")
        case .gridConsumption:
            return String(localized: "Power coming from the grid")
        }
    }

    public var colour: Color {
        switch self {
        case .generation:
            return .yellow.opacity(0.8)
        case .feedIn:
            return .mint.opacity(0.8)
        case .chargeEnergyToTal:
            return .green.opacity(0.8)
        case .dischargeEnergyToTal:
            return .red.opacity(0.5)
        case .gridConsumption:
            return .red.opacity(0.8)
        }
    }
}
