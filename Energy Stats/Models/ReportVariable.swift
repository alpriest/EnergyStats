//
//  ReportVariable.swift
//  Energy Stats
//
//  Created by Alistair Priest on 14/11/2022.
//

import Foundation

enum ReportVariable: String, RawRepresentable {
    case feedIn
    case generation
    case gridConsumption
    case chargeEnergyTotal
    case dischargeEnergyTotal

    var networkTitle: String {
        switch self {
        case .chargeEnergyTotal:
            return "chargeEnergyToTal"
        case .dischargeEnergyTotal:
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
            self = .chargeEnergyTotal
        case "dischargeEnergyToTal":
            self = .dischargeEnergyTotal
        default:
            return nil
        }
    }
}
