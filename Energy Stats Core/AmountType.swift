//
//  AmountType.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 19/08/2023.
//

import Foundation

public enum AmountType {
    case solarFlow
    case batteryFlow
    case batteryCapacity
    case homeFlow
    case gridFlow
    case selfSufficiency
    case totalYield
    case homeUsage
    case `default`
}

extension AmountType {
    func accessibilityLabel(amount: Double, amountWithUnit: String) -> String {
        switch self {
        case .solarFlow:
            return String(format: String(accessibilityKey: .currentSolarGenerationAmount), arguments: [amountWithUnit])
        case .batteryFlow:
            if amount > 0 {
                return String(format: String(accessibilityKey: .batteryStoringRate), arguments: [amountWithUnit])
            } else {
                return String(format: String(accessibilityKey: .batteryEmptyingRate), arguments: [amountWithUnit])
            }
        case .batteryCapacity:
            return String(format: String(accessibilityKey: .batteryCapacity), arguments: [amountWithUnit])
        case .homeFlow:
            return String(format: String(accessibilityKey: .homeConsumptionRate), arguments: [amountWithUnit])
        case .gridFlow:
            if amount > 0 {
                return String(format: String(accessibilityKey: .gridExportRate), arguments: [amountWithUnit])
            } else {
                return String(format: String(accessibilityKey: .gridConsumptionRate), arguments: [amountWithUnit])
            }
        case .selfSufficiency:
            return amountWithUnit
        case .totalYield:
            return String(format: String(accessibilityKey: .totalYield), arguments: [amountWithUnit])
        case .homeUsage:
            return String(format: String(accessibilityKey: .homeTotalUsage), arguments: [amountWithUnit])
        case .default:
            return amountWithUnit
        }
    }
}
