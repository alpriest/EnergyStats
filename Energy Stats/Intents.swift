//
//  Intents.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/08/2023.
//

import Foundation
import AppIntents
import Energy_Stats_Core

@available(iOS 16.0, *)
struct CheckBatteryChargeLevelIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Storage Battery SOC"
    static var description: IntentDescription? = "Returns the battery state of charge as a percentage"
    static var authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = KeychainStore()
        let network = Network(credentials: store, store: InMemoryLoggingNetworkStore())
        let config = UserDefaultsConfig()
        guard let deviceID = config.selectedDeviceID else {
            throw ConfigManager.NoDeviceFoundError()
        }
        let battery = try await network.fetchBattery(deviceID: deviceID)

        return .result(value: battery.soc, dialog: IntentDialog(stringLiteral: "\(battery.soc)%"))
    }
}

@available(iOS 16.0, *)
struct EnergyStatsShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CheckBatteryChargeLevelIntent(),
            phrases: ["Show me my battery SOC on \(.applicationName)"],
            shortTitle: "Battery SOC"
        )
    }
}
