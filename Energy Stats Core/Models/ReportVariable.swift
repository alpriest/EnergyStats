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
    case pvEnergyTotal
    case inverterConsumption

    public var networkTitle: String {
        switch self {
        case .feedIn:
            return "feedin"
        case .chargeEnergyToTal:
            return "chargeEnergyToTal"
        case .dischargeEnergyToTal:
            return "dischargeEnergyToTal"
        case .pvEnergyTotal:
            return "PVEnergyTotal"
        case .inverterConsumption:
            return String(localized: "Inverter consumption")
        default:
            return self.rawValue
        }
    }

    public init?(rawValue: String) {
        switch rawValue {
        case Self.generation.networkTitle:
            self = .generation
        case Self.feedIn.networkTitle:
            self = .feedIn
        case Self.gridConsumption.networkTitle:
            self = .gridConsumption
        case Self.chargeEnergyToTal.networkTitle:
            self = .chargeEnergyToTal
        case Self.dischargeEnergyToTal.networkTitle:
            self = .dischargeEnergyToTal
        case Self.loads.networkTitle:
            self = .loads
        case Self.pvEnergyTotal.networkTitle:
            self = .pvEnergyTotal
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
        case .pvEnergyTotal:
            return String(localized: "Solar ") + usage.title()
        case .inverterConsumption:
            return String(localized: "Inverter consumption")
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
            return Color.loadsPower.opacity(0.8)
        case .selfSufficiency:
            return .black
        case .pvEnergyTotal:
            return .yellow.opacity(0.8)
        case .inverterConsumption:
            return .pink.opacity(0.8)
        }
    }
}
