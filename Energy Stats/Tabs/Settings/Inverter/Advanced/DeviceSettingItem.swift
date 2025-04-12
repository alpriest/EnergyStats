//
//  DeviceSettingItem.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/04/2025.
//

import SwiftUI
import Energy_Stats_Core

extension DeviceSettingsItem {
    var title: String {
        switch self {
        case .exportLimit:
            "Export Limit"
        case .maxSoc:
            "Max SoC"
        case .minSoc, .minSocOnGrid, .gridCode:
            ""
        }
    }

    var description: String {
        switch self {
        case .exportLimit:
            "Sets the maximum power that the inverter can export to the grid."
        case .maxSoc:
            "Sets the highest charge level the battery is allowed to reach, expressed as a percentage."
        case .minSoc, .minSocOnGrid, .gridCode:
            ""
        }
    }

    var behaviour: String {
        switch self {
        case .exportLimit:
            "By configuring this setting, you can control the amount of energy sent back to the grid, ensuring compliance with local regulations or personal preferences. For example, if local regulations limit export capacity, setting this value ensures the inverter does not exceed the specified limit."
        case .maxSoc:
            "Charging stops once the battery hits the Max SoC. Can be adjusted based on usage patterns or to align with energy tariffs and solar availability."
        case .minSoc, .minSocOnGrid, .gridCode:
            ""
        }
    }

    var fallbackUnit: String {
        switch self {
        case .maxSoc:
            "%"
        default:
            ""
        }
    }
}
