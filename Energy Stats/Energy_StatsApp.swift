//
//  Energy_StatsApp.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI
import WatchConnectivity

@main
struct Energy_StatsApp: App {
    static let delegate = WatchSessionDelegate()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        let keychainStore = KeychainStore()
        var config: Config
        if isRunningScreenshots() {
            config = MockConfig()
        } else {
            config = UserDefaultsConfig()
        }
        let appSettingsPublisher = AppSettingsPublisherFactory.make(from: config)
        let network = NetworkService.standard(keychainStore: keychainStore,
                                              isDemoUser: { config.isDemoUser },
                                              dataCeiling: { config.dataCeiling })
        let configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher, keychainStore: keychainStore)
        let userManager = UserManager(store: keychainStore, configManager: configManager, networkCache: InMemoryLoggingNetworkStore.shared)
        let solarForecastProvider: () -> SolarForecasting = {
            config.isDemoUser ? DemoSolcast() : SolcastCache(service: { Solcast() })
        }
        let versionChecker = VersionChecker()
        let templateStore = TemplateStore(config: configManager)

        return WindowGroup {
            if isRunningTests() {
                Text("Tests")
            } else {
                ContentView(
                    userManager: userManager,
                    network: network,
                    configManager: configManager,
                    solarForecastProvider: solarForecastProvider,
                    templateStore: templateStore
                )
                .environmentObject(InMemoryLoggingNetworkStore.shared)
                .environmentObject(userManager)
                .environmentObject(KeychainWrapper(keychainStore))
                .environmentObject(versionChecker)
                .onChange(of: scenePhase) { phase in
                    if case .active = phase {
                        if WCSession.isSupported() {
                            let session = WCSession.default
                            session.delegate = Energy_StatsApp.delegate
                            Energy_StatsApp.delegate.config = configManager
                            session.activate()
                        }
                    }
                }
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
