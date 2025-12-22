//
//  WorkMode.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 07/08/2023.
//

import Foundation
import SwiftUI

public typealias WorkMode = String

public extension WorkMode {
    static var SelfUse = "SelfUse"
    static var Feedin = "Feedin"
    static var Backup = "Backup"
    static var ForceCharge = "ForceCharge"
    static var ForceDischarge = "ForceDischarge"
    static var PeakShaving = "PeakShaving"
    
    static func title(for workmode: WorkMode) -> String {
        switch workmode {
        case "SelfUse":
            return "Self Use"
        case "Feedin":
            return "Feed In First"
        case "Backup":
            return "Backup"
        case "ForceCharge":
            return "Force Charge"
        case "ForceDischarge":
            return "Force Discharge"
        case "PeakShaving":
            return "Peak Shaving"
        default:
            return workmode
        }
    }
    
    static func networkTitle(for workMode: WorkMode) -> String {
        switch workMode {
        case .SelfUse:
            "SelfUse"
        case .Feedin:
            "Feedin"
        case .Backup:
            "Backup"
        case .ForceCharge:
            "ForceCharge"
        case .ForceDischarge:
            "ForceDischarge"
        default:
            workMode
        }
    }
}

extension WorkMode {    
    public var title: String {
        WorkMode.title(for: self)
    }
    
    @ViewBuilder
    public var subtitle: some View {
        switch self {
        case "SelfUse":
            Text("workmode.self_use_mode.description")
        case "Feedin":
            Text("workmode.feed_in_first_mode.description")
        case "Backup":
            Text("workmode.backup_mode.description")
        case "ForceCharge(AC)":
            Text("workmode.force_charge_mode_ac.description")
        case "ForceDischarge(AC)":
            Text("workmode.force_discharge_mode_ac.description")
        case "PeakShaving":
            Text("workmode.peak_shaving.description")
        case "ForceCharge(BAT)":
            Text("workmode.force_charge_mode_bat.description")
        case "ForceDischarge(BAT)":
            Text("workmode.force_discharge_mode_bat.description")
        default:
            EmptyView()
        }
    }
}

public enum UNUSED_WorkMode: String, Codable, RawRepresentable {
    case SelfUse
    case Feedin
    case Backup
    case ForceCharge
    case ForceDischarge
    case Invalid
    case PeakShaving
    case Unsupported

    public var networkTitle: String {
        switch self {
        case .SelfUse:
            "SelfUse"
        case .Feedin:
            "Feedin"
        case .Backup:
            "Backup"
        case .ForceCharge:
            "ForceCharge"
        case .ForceDischarge:
            "ForceDischarge"
        case .Invalid, .PeakShaving, .Unsupported:
            ""
        }
    }

    @ViewBuilder
    public var subtitle: some View {
        switch self {
        case .SelfUse:
            Text("workmode.self_use_mode.description")
        case .Feedin:
            Text("workmode.feed_in_first_mode.description")
        case .Backup:
            Text("workmode.backup_mode.description")
        case .ForceCharge:
            Text("workmode.force_charge_mode.description")
        case .ForceDischarge:
            Text("workmode.forceDischarge.description")
        case .Invalid, .Unsupported:
            EmptyView()
        case .PeakShaving:
            Text("workmode.peak_shaving.description")
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try? container.decode(String.self)
        self = UNUSED_WorkMode(rawValue: value ?? "") ?? .Unsupported
    }
}

