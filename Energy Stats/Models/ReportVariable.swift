//
//  ReportVariable.swift
//  Energy Stats
//
//  Created by Alistair Priest on 14/11/2022.
//

import SwiftUI

enum ReportVariable: String, RawRepresentable {
    case feedIn
    case generation
    case gridConsumption
    case chargeEnergyToTal
    case dischargeEnergyToTal

    var networkTitle: String {
        switch self {
        case .chargeEnergyToTal:
            return "chargeEnergyToTal"
        case .dischargeEnergyToTal:
            return "dischargeEnergyToTal"
        default:
            return self.rawValue
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case "feedIn":
            self = .feedIn
        case "generation":
            self = .generation
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

    var title: String {
        switch self {
        case .generation:
            return "Output power"
        case .feedIn:
            return "Feed-in power"
        case .chargeEnergyToTal:
            return "Charge power"
        case .dischargeEnergyToTal:
            return "Discharge power"
        case .gridConsumption:
            return "Grid consumption power"
        }
    }

    var description: String {
        switch self {
        case .generation:
            return "PV / Battery power coming through the inverter"
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

    var colour: Color {
        switch self {
        case .chargeEnergyToTal:
            return .green.opacity(0.8)
        case .dischargeEnergyToTal:
            return .red.opacity(0.5)
        case .generation:
            return .yellow.opacity(0.8)
        case .gridConsumption:
            return .red.opacity(0.8)
        case .feedIn:
            return .mint.opacity(0.8)
        }
    }
}
