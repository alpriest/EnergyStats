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
        appSettingsPublisher = AppSettingsPublisherFactory.make(from: config)

        configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher, keychainStore: keychainStore)
        userManager = .init(store: keychainStore, configManager: configManager, networkCache: InMemoryLoggingNetworkStore.shared)
        templateStore = TemplateStore(config: configManager)
        appSettingsPublisher
            .sink { [keychainStore] settings in
                Self.updateKeychainSettingsForWatch(keychainStore: keychainStore, settings: settings)
            }.store(in: &cancellables)
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

    private static func updateKeychainSettingsForWatch(keychainStore: KeychainStoring, settings: AppSettings) {
        try? keychainStore.store(key: .showGridTotalsOnPowerFlow, value: settings.showGridTotalsOnPowerFlow)
    }
}

class KeychainWrapper: ObservableObject {
    var store: KeychainStoring

    init(_ store: KeychainStoring) {
        self.store = store
    }
}
