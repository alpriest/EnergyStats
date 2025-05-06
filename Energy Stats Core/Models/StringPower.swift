//
//  StringPower.swift
//
//
//  Created by Alistair Priest on 12/03/2025.
//

import Foundation

public struct StringPower: Identifiable {
    public let name: String
    public let amount: Double

    public var id: String { self.name }

    public init(name: String, amount: Double) {
        self.name = name
        self.amount = amount
    }

    public func displayName(settings: PowerFlowStringsSettings) -> String {
        switch self.name {
        case "PV1":
            return settings.pv1Name
        case "PV2":
            return settings.pv2Name
        case "PV3":
            return settings.pv3Name
        case "PV4":
            return settings.pv4Name
        case "PV5":
            return settings.pv5Name
        case "CT2":
            return "CT2"
        default:
            return settings.pv6Name
        }
    }

    public var stringType: StringType {
        switch name {
        case "PV1":
            return .pv1
        case "PV2":
            return .pv2
        case "PV3":
            return .pv3
        case "PV4":
            return .pv4
        case "PV5":
            return .pv5
        case "CT2":
            return .ct2
        default:
            return .pv6
        }
    }
}
