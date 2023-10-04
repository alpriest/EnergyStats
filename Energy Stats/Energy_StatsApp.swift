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
        let store = InMemoryLoggingNetworkStore()
        let network = NetworkFacade(network: NetworkCache(network: Network(credentials: keychainStore, store: store)),
                                    config: config,
                                    store: keychainStore)
        let configManager = ConfigManager(networking: network, config: config)
        let userManager = UserManager(networking: network, store: keychainStore, configManager: configManager, networkCache: store)

        return WindowGroup {
            if isRunningTests() {
                Text("Tests")
            } else {
                ContentView(
                    loginManager: userManager,
                    network: network,
                    configManager: configManager
                )
                .environmentObject(store)
                .environmentObject(userManager)
                .task {
                    if isRunningScreenshots() {
                        config.financialModel = 0
                        config.showFinancialEarnings = true
                    }
                }
            }
        }
    }

    func isRunningTests() -> Bool {
        CommandLine.arguments.contains("-TESTING=1")
    }

    func isRunningScreenshots() -> Bool {
        CommandLine.arguments.contains("screenshots")
    }
}
