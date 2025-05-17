//
//  Energy_StatsApp.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Combine
import Energy_Stats_Core
import Firebase
import FirebaseAnalytics
import SwiftUI
import WatchConnectivity
import WidgetKit
import Pulse
import PulseUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        if !isRunningTests() || !isRunningScreenshots() {
            FirebaseApp.configure()
        }

        return true
    }
}

@main
struct Energy_StatsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    static let delegate = WatchSessionDelegate()
    let keychainStore = KeychainStore()

    let urlSession = URLSessionProxy(configuration: .default)
    let appSettingsPublisher: LatestAppSettingsPublisher
    let config: Config
    let network: Networking
    let configManager: ConfigManaging
    let userManager: UserManager
    let versionChecker: VersionChecker
    let templateStore: TemplateStoring
    let bannerAlertManager = BannerAlertManager()
    private var cancellables = Set<AnyCancellable>()

    @Environment(\.scenePhase) private var scenePhase

    init() {
        var config: Config
        if isRunningScreenshots() {
            config = MockConfig()
        } else {
            config = UserDefaultsConfig()
        }

        UserSettings.shared.allowedShareStoreOutputs = [.har]

        self.config = config
        network = NetworkService.standard(keychainStore: keychainStore,
                                          urlSession: urlSession,
                                          isDemoUser: { config.isDemoUser },
                                          dataCeiling: { config.dataCeiling })
        appSettingsPublisher = AppSettingsPublisherFactory.make()
        configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher, keychainStore: keychainStore)
        AppSettingsPublisherFactory.update(from: configManager)
        userManager = .init(store: keychainStore, configManager: configManager)
        templateStore = TemplateStore(config: configManager)
        appSettingsPublisher
            .sink { [keychainStore, configManager] _ in
                Self.updateKeychainSettingsForWatch(keychainStore: keychainStore, configManager: configManager)
            }.store(in: &cancellables)
        versionChecker = VersionChecker(urlSession: urlSession)
    }

    var body: some Scene {
        let solarForecastProvider: () -> SolcastCaching = {
            config.isDemoUser ? DemoSolcast() : SolcastCache(service: { Solcast(urlSession: urlSession, configManager: configManager) })
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
                .environmentObject(userManager)
                .environmentObject(KeychainWrapper(keychainStore))
                .environmentObject(versionChecker)
                .environmentObject(bannerAlertManager)
                .onChange(of: scenePhase) { phase in
                    if case .active = phase {
                        if WCSession.isSupported() {
                            let session = WCSession.default
                            session.delegate = Energy_StatsApp.delegate
                            Energy_StatsApp.delegate.config = configManager
                            session.activate()
                        }

                        Task {
                            await refreshSolcast(solarForecastProvider: solarForecastProvider)
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

    private static func updateKeychainSettingsForWatch(keychainStore: KeychainStoring, configManager: ConfigManaging) {
        try? keychainStore.store(key: .deviceSN, value: configManager.selectedDeviceSN)
        try? keychainStore.store(key: .showGridTotalsOnPowerFlow, value: configManager.showGridTotalsOnPowerFlow)
        try? keychainStore.store(key: .batteryCapacity, value: configManager.batteryCapacity)
        try? keychainStore.store(key: .shouldInvertCT2, value: configManager.shouldInvertCT2)
        try? keychainStore.store(key: .minSOC, value: configManager.minSOC)
        try? keychainStore.store(key: .shouldCombineCT2WithPVPower, value: configManager.shouldCombineCT2WithPVPower)
        try? keychainStore.store(key: .showUsableBatteryOnly, value: configManager.showUsableBatteryOnly)
    }

    private func refreshSolcast(solarForecastProvider: SolarForecastProviding) async {
        guard configManager.fetchSolcastOnAppLaunch else { return }
        guard let apiKey = configManager.solcastSettings.apiKey else { return }

        let service = solarForecastProvider()

        do {
            _ = try await configManager.solcastSettings.sites.asyncMap { site in
                _ = try await service.fetchForecast(for: site, apiKey: apiKey, ignoreCache: false)
            }
        } catch {
            // Ignore
        }
    }
}

class KeychainWrapper: ObservableObject {
    var store: KeychainStoring

    init(_ store: KeychainStoring) {
        self.store = store
    }
}

func isRunningTests() -> Bool {
    CommandLine.arguments.contains("-TESTING=1")
}

func isRunningScreenshots() -> Bool {
    CommandLine.arguments.contains("screenshots")
}
