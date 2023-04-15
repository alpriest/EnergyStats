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

public enum RawVariable: String, RawRepresentable {
    case generationPower
    case feedinPower
    case batChargePower
    case batDischargePower
    case gridConsumptionPower
    case loadsPower

    public var reportVariable: ReportVariable? {
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

    public func title(as usage: ValueUsage) -> String {
        switch self {
        case .generationPower:
            return "Output " + usage.rawValue
        case .feedinPower:
            return "Feed-in " + usage.rawValue
        case .batChargePower:
            return "Charge " + usage.rawValue
        case .batDischargePower:
            return "Discharge " + usage.rawValue
        case .gridConsumptionPower:
            return "Grid consumption " + usage.rawValue
        case .loadsPower:
            return "Loads " + usage.rawValue
        }
    }

    public var networkTitle: String {
        self.rawValue
    }

    public var colour: Color {
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

    public var description: String {
        switch self {
        case .generationPower:
            return "Solar / Battery power coming through the inverter"
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
