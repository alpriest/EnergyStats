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
            "Max"
        case .minSoc, .minSocOnGrid, .gridCode:
            ""
        }
    }

    var description: String {
        switch self {
        case .exportLimit:
            "Sets the maximum power that the inverter can export to the grid."
        case .maxSoc:
            "Maximum SoC"
        case .minSoc, .minSocOnGrid, .gridCode:
            ""
        }
    }

    var behaviour: String {
        switch self {
        case .exportLimit:
            "By configuring this setting, you can control the amount of energy sent back to the grid, ensuring compliance with local regulations or personal preferences. For example, if local regulations limit export capacity, setting this value ensures the inverter does not exceed the specified limit."
        case .maxSoc:
            "Maximum SoC"
        case .minSoc, .minSocOnGrid, .gridCode:
            ""
        }
    }
}
