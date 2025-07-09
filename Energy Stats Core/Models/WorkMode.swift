//
//  WorkMode.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 07/08/2023.
//

import Foundation
import SwiftUI

public enum WorkMode: String, CaseIterable, Codable, RawRepresentable, Describable {
    case SelfUse
    case Feedin
    case Backup
    case ForceCharge
    case ForceDischarge
    case Invalid
    case PeakShaving

    public var title: String {
        switch self {
        case .SelfUse:
            return "Self Use"
        case .Feedin:
            return "Feed In First"
        case .Backup:
            return "Backup"
        case .ForceCharge:
            return "Force Charge"
        case .ForceDischarge:
            return "Force Discharge"
        case .PeakShaving:
            return "Peak Shaving"
        case .Invalid:
            return ""
        }
    }

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
        case .Invalid:
            ""
        case .PeakShaving:
            ""
        }
    }

    public static var values: [WorkMode] {
        WorkMode.allCases.filter { $0.title != "" }
    }
}
