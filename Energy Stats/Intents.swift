//
//  Intents.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/08/2023.
//

import AppIntents
import Energy_Stats_Core
import Foundation

struct CheckBatteryChargeLevelIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Storage Battery SOC"
    static var description: IntentDescription? = "Returns the battery state of charge as a percentage"
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some ProvidesDialog & ReturnsValue<Int> {
        let store = KeychainStore()
        let config = UserDefaultsConfig()
        let network = NetworkService.standard(keychainStore: store,
                                              isDemoUser: { false },
                                              dataCeiling: { .none })
        guard let deviceSN = config.selectedDeviceSN else {
            throw ConfigManager.NoDeviceFoundError()
        }
        let real = try await network.fetchRealData(deviceSN: deviceSN, variables: ["SoC", "SoC_1"])
        let soc = Int(real.datas.SoC())

        return .result(value: soc, dialog: IntentDialog(stringLiteral: "\(soc)%"))
    }
}

struct EnergyStatsShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CheckBatteryChargeLevelIntent(),
            phrases: ["Check my storage battery SOC on \(.applicationName)"],
            shortTitle: "Storage Battery SOC"
        )
    }
}
