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
import Network
import os
import Pulse
import PulseUI
import SwiftUI
import WatchConnectivity
import WidgetKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        if !isRunningTests() || !isRunningScreenshots() {
            FirebaseApp.configure()
            CoreBusReceiver.observeAnalyticsEvent()
        }

        return true
    }
}

@main
struct Energy_StatsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    static let watchDelegate = PhoneToWatchSessionDelegate()
    let keychainStore = KeychainStore()

    let urlSession = URLSessionProxy(configuration: .default)
    let appSettingsStore: AppSettingsStore
    let config: StoredConfig
    let network: Networking
    let configManager: ConfigManaging
    let userManager: UserManager
    let versionChecker: VersionChecker
    let templateStore: TemplateStoring
    let bannerAlertManager = BannerAlertManager()
    private var cancellables = Set<AnyCancellable>()

    @Environment(\.scenePhase) private var scenePhase

    init() {
        nw_tls_create_options()

        let config: StoredConfig = if isRunningScreenshots() {
            MockConfig()
        } else {
            UserDefaultsConfig()
        }
        self.config = config
        
        // Pulse
        UserSettings.shared.allowedShareStoreOutputs = [.har]

        network = NetworkService.standard(apiTokenProvider: { [keychainStore] in try? keychainStore.getToken() },
                                          urlSession: urlSession,
                                          tracer: FirebaseNetworkTracer(),
                                          isDemoUser: { config.isDemoUser },
                                          dataCeiling: { config.dataCeiling })
        appSettingsStore = AppSettingsStoreFactory.make()
        configManager = ConfigManager(networking: network, config: config, appSettingsStore: appSettingsStore, keychainStore: keychainStore)
        AppSettingsStoreFactory.update(from: configManager)
        userManager = .init(store: keychainStore, configManager: configManager)
        templateStore = TemplateStore(config: configManager)
        userManager.$isLoggedIn
            .combineLatest(appSettingsStore.publisher)
            .sink { [keychainStore] isLoggedIn, _ in
                let apiKey = try? keychainStore.getToken()
                
                if let isLoggedIn {
                    Self.watchDelegate.sendCurrentConfig(apiKey: apiKey, isLoggedIn: isLoggedIn)
                }
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
                        performOnActivationTasks(solarForecastProvider: solarForecastProvider)
                    }
                }
                .task {
                    versionChecker.load()
                }
            }
        }
    }

    private func performOnActivationTasks(solarForecastProvider: SolarForecastProviding) {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = Energy_StatsApp.watchDelegate
            Energy_StatsApp.watchDelegate.config = configManager
            Energy_StatsApp.watchDelegate.userManager = userManager
            session.activate()
        }

        fetchDeviceCapacity()
        refreshSolcast(solarForecastProvider: solarForecastProvider)
        fetchCurrentInverterSchedule()
    }
    
    private func fetchDeviceCapacity() {
        guard
            configManager.currentDevice.value?.capacity == nil,
            userManager.isLoggedIn == true
        else { return }
        
        Task {
            do {
                try await configManager.fetchDevices()
            } catch {
                // ignore
            }
        }
    }

    private func refreshSolcast(solarForecastProvider: SolarForecastProviding) {
        guard configManager.fetchSolcastOnAppLaunch else { return }
        guard let apiKey = configManager.solcastSettings.apiKey else { return }

        let service = solarForecastProvider()

        Task {
            do {
                _ = try await configManager.solcastSettings.sites.asyncMap { site in
                    _ = try await service.fetchForecast(for: site, apiKey: apiKey, ignoreCache: false)
                }
            } catch {
                // Ignore
            }
        }
    }

    private func fetchCurrentInverterSchedule() {
        guard configManager.showInverterScheduleQuickLink else { return }

        Task {
            guard let deviceSN = configManager.selectedDeviceSN else { return }
            let isEnabled = try await network.fetchSchedulerFlag(deviceSN: deviceSN)
            guard isEnabled.enable else { return }

            let scheduleResponse = try await network.fetchCurrentSchedule(deviceSN: deviceSN)
            let schedule = Schedule(scheduleResponse: scheduleResponse)

            configManager.scheduleTemplates.forEach { template in
                let templatePhases = template.asSchedule().phases
                    .sorted { first, second in
                        first.start < second.start
                    }
                let match = zip(templatePhases, schedule.phases).allSatisfy { templatePhase, schedulePhase in
                    templatePhase.isEqualConfiguration(to: schedulePhase)
                }
                if match {
                    let appSettings = appSettingsStore.currentValue.copy(detectedActiveTemplate: template.name)
                    appSettingsStore.update(appSettings)
                }
            }
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
