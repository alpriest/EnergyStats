//
//  Energy_StatsApp.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

@main
struct Energy_StatsApp: App {
    var body: some Scene {
        let keychainStore = KeychainStore()
        let config = UserDefaultsConfig()
        let store = InMemoryLoggingNetworkStore.shared
        let facade = NetworkFacade(network: NetworkCache(network: Network(credentials: keychainStore, store: store)),
                                   config: config,
                                   store: keychainStore)
        let appSettingsPublisher = AppSettingsPublisherFactory.make(from: config)
        let network = NetworkValueCleaner(network: facade, appSettingsPublisher: appSettingsPublisher)
        let configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher)
        let userManager = UserManager(networking: network, store: keychainStore, configManager: configManager, networkCache: store)
        let solarForecastProvider: () -> SolarForecasting = {
            config.isDemoUser ? DemoSolcast() : SolcastCache(service: { Solcast() })
        }

        return WindowGroup {
            if isRunningTests() {
                Text("Tests")
            } else {
                ContentView(
                    loginManager: userManager,
                    network: network,
                    configManager: configManager,
                    solarForecastProvider: solarForecastProvider
                )
                .environmentObject(store)
                .environmentObject(userManager)
                .task {
                    try? keychainStore.store(apiKey: "648d67a7-80af-4520-9873-0c8a9f6ddb27")
                    if isRunningScreenshots() {
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
