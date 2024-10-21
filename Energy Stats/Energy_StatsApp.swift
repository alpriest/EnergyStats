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
import WidgetKit

@main
struct Energy_StatsApp: App {
    static let delegate = WatchSessionDelegate()
    let keychainStore = KeychainStore()

    let appSettingsPublisher: LatestAppSettingsPublisher
    let config: Config
    let network: Networking
    let configManager: ConfigManaging
    let userManager: UserManager
    let versionChecker = VersionChecker()
    let templateStore: TemplateStoring
    private var cancellables = Set<AnyCancellable>()

    @Environment(\.scenePhase) private var scenePhase

    init() {
        var config: Config
        if Self.isRunningScreenshots() {
            config = MockConfig()
        } else {
            config = UserDefaultsConfig()
        }

        self.config = config
        network = NetworkService.standard(keychainStore: keychainStore,
                                          isDemoUser: { config.isDemoUser },
                                          dataCeiling: { config.dataCeiling })
        appSettingsPublisher = AppSettingsPublisherFactory.make()
        configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher, keychainStore: keychainStore)
        AppSettingsPublisherFactory.update(from: configManager)
        userManager = .init(store: keychainStore, configManager: configManager, networkCache: InMemoryLoggingNetworkStore.shared)
        templateStore = TemplateStore(config: configManager)
        appSettingsPublisher
            .sink { [keychainStore, configManager] _ in
                Self.updateKeychainSettingsForWatch(keychainStore: keychainStore, configManager: configManager)
            }.store(in: &cancellables)

        WidgetCenter.shared.reloadAllTimelines()
    }

    var body: some Scene {
        let solarForecastProvider: () -> SolarForecasting = {
            config.isDemoUser ? DemoSolcast() : SolcastCache(service: { Solcast() })
        }

        return WindowGroup {
            if isRunningTests() {
                Text("Tests")
            } else {
                ContentView(
                    network: network,
                    configManager: configManager,
                    solarForecastProvider: solarForecastProvider,
                    templateStore: templateStore
                )
                .environmentObject(InMemoryLoggingNetworkStore.shared)
                .environmentObject(userManager)
                .environmentObject(KeychainWrapper(keychainStore))
                .environmentObject(versionChecker)
                .environmentObject(SlowServerBannerAlertManager())
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
                    //                    Scheduler.scheduleRefresh()
                }
            }
        }
    }

    func isRunningTests() -> Bool {
        CommandLine.arguments.contains("-TESTING=1")
    }

    static func isRunningScreenshots() -> Bool {
        CommandLine.arguments.contains("screenshots")
    }

    private static func updateKeychainSettingsForWatch(keychainStore: KeychainStoring, configManager: ConfigManaging) {
        try? keychainStore.store(key: .deviceSN, value: configManager.selectedDeviceSN)
        try? keychainStore.store(key: .showGridTotalsOnPowerFlow, value: configManager.showGridTotalsOnPowerFlow)
        try? keychainStore.store(key: .batteryCapacity, value: configManager.batteryCapacity)
        try? keychainStore.store(key: .shouldInvertCT2, value: configManager.shouldInvertCT2)
        try? keychainStore.store(key: .minSOC, value: configManager.minSOC)
        try? keychainStore.store(key: .shouldCombineCT2WithPVPower, value: configManager.shouldCombineCT2WithPVPower)
        try? keychainStore.store(key: .showUsableBatteryOnly, value: configManager.showUsableBatteryOnly)
    }
}

class KeychainWrapper: ObservableObject {
    var store: KeychainStoring

    init(_ store: KeychainStoring) {
        self.store = store
    }
}
