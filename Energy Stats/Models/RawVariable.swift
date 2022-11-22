//
//  RawVariable.swift
//  Energy Stats
//
//  Created by Alistair Priest on 12/09/2022.
//

import SwiftUI

enum RawVariable: String, RawRepresentable {
    case generationPower
    case feedinPower
    case batChargePower
    case batDischargePower
    case gridConsumptionPower
    case loadsPower

    var reportVariable: ReportVariable? {
        switch self {
        case .generationPower:
            return .generation
        case .feedinPower:
            return .feedIn
        case .batChargePower:
            return .chargeEnergyToTal
        case .batDischargePower:
            return .dischargeEnergyToTal
        case .gridConsumptionPower:
            return .gridConsumption
        case .loadsPower:
            return nil
        }
    }

    var title: String {
        switch self {
        case .generationPower:
            return "Output power"
        case .feedinPower:
            return "Feed-in power"
        case .batChargePower:
            return "Charge power"
        case .batDischargePower:
            return "Discharge power"
        case .gridConsumptionPower:
            return "Grid consumption power"
        case .loadsPower:
            return "Loads power"
        }
    }

    var networkTitle: String {
        self.rawValue
    }

    var colour: Color {
        switch self {
        case .batChargePower:
            return .green.opacity(0.8)
        case .batDischargePower:
            return .red.opacity(0.5)
        case .generationPower:
            return .yellow.opacity(0.8)
        case .gridConsumptionPower:
            return .red.opacity(0.8)
        case .feedinPower:
            return .mint.opacity(0.8)
        case .loadsPower:
            return .black.opacity(0.2)
        }
    }

    var description: String {
        switch self {
        case .generationPower:
            return "PV / Battery power coming through the inverter"
        case .feedinPower:
            return "Power being sent to the grid"
        case .batChargePower:
            return "Power charging the battery"
        case .batDischargePower:
            return "Power discharging from the battery"
        case .gridConsumptionPower:
            return "Power coming from the grid"
        case .loadsPower:
            return "Loads power"
        }
    }
}
