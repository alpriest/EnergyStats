//
//  Energy_StatsApp.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Energy_Stats_Core
import SwiftUI

@main
struct Energy_StatsApp: App {
    var body: some Scene {
        let keychainStore = KeychainStore()
        let config = UserDefaultsConfig()
        let network = NetworkFacade(network: Network(credentials: keychainStore, config: config),
                                    config: config)
        let configManager = ConfigManager(networking: network, config: config)
        let loginManager = UserManager(networking: network, store: keychainStore, configManager: configManager)
        Task { try await configManager.fetchFirmwareVersions() }

        return WindowGroup {
            if isRunningTests() {
                Text("Tests")
            } else {
                ContentView(
                    loginManager: loginManager,
                    network: network,
                    configManager: configManager
                )
            }
        }
    }

    func isRunningTests() -> Bool {
        CommandLine.arguments.contains("-TESTING=1")
    }
}
