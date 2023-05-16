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
        switch self {
        case .generation:
            return "Output energy"
        case .feedIn:
            return "Feed-in energy"
        case .chargeEnergyToTal:
            return "Charge energy"
        case .dischargeEnergyToTal:
            return "Discharge energy"
        case .gridConsumption:
            return "Grid consumption energy"
        }
    }

    public var description: String {
        switch self {
        case .generation:
            return "Solar / Battery power coming through the inverter"
        case .feedIn:
            return "Power being sent to the grid"
        case .chargeEnergyToTal:
            return "Power charging the battery"
        case .dischargeEnergyToTal:
            return "Power discharging from the battery"
        case .gridConsumption:
            return "Power coming from the grid"
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
