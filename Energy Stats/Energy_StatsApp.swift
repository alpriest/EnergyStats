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
        var config: Config
        if isRunningScreenshots() {
            config = UserDefaultsConfig()
        } else {
            config = MockConfig()
        }
        let appSettingsPublisher = AppSettingsPublisherFactory.make(from: config)
        let network = NetworkService.standard(keychainStore: keychainStore, config: config)
        let configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher)
        let userManager = UserManager(networking: network, store: keychainStore, configManager: configManager, networkCache: InMemoryLoggingNetworkStore.shared)
        let solarForecastProvider: () -> SolarForecasting = {
            config.isDemoUser ? DemoSolcast() : SolcastCache(service: { Solcast() })
        }
        let versionChecker = VersionChecker()

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
                .environmentObject(InMemoryLoggingNetworkStore.shared)
                .environmentObject(userManager)
                .environmentObject(KeychainWrapper(keychainStore))
                .environmentObject(versionChecker)
                .task {
                    versionChecker.load()
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

class KeychainWrapper: ObservableObject {
    var store: KeychainStoring

    init(_ store: KeychainStoring) {
        self.store = store
    }
}
