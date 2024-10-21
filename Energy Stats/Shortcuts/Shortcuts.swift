//
//  Intents.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/08/2023.
//

import AppIntents
import Foundation

struct EnergyStatsShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CheckBatteryChargeLevelIntent(),
            phrases: ["Check my storage battery SOC on \(.applicationName)"],
            shortTitle: "Storage Battery SOC"
        )
        AppShortcut(
            intent: CheckCurrentSolarGenerationIntent(),
            phrases: ["Check my current solar generation"],
            shortTitle: "Solar Generation"
        )
        AppShortcut(
            intent: CheckCurrentHouseLoadIntent(),
            phrases: ["Check my current house load"],
            shortTitle: "House Load"
        )
        AppShortcut(
            intent: CheckCurrentGridLoadIntent(),
            phrases: ["Check my current grid load"],
            shortTitle: "Grid Load"
        )
    }
}
