//
//  Energy_Stats_Watch_AppApp.swift
//  Energy Stats Watch App Watch App
//
//  Created by Alistair Priest on 27/04/2024.
//

import Energy_Stats_Core
import SwiftUI
import WatchConnectivity

@main
struct Energy_Stats_Watch_App: App {
    static let delegate = WatchSessionDelegate()
    @Environment(\.scenePhase) private var scenePhase
    @WKApplicationDelegateAdaptor var appDelegate: EnergyStatsWatchAppDelegate

    var keychainStore: KeychainStoring = {
        if ProcessInfo().arguments.contains("mockDevice") {
            StubKeychainStore()
        } else {
            KeychainStore()
        }
    }()

    var network: Networking = {
        if ProcessInfo().arguments.contains("mockDevice") {
            NetworkService.preview()
        } else {
            NetworkService.standard(keychainStore: KeychainStore(),
                                    isDemoUser: { false },
                                    dataCeiling: { .none })
        }
    }()

    var body: some Scene {
        let configManager = WatchConfigManager(keychainStore: keychainStore)

        WindowGroup {
            ContentView(keychainStore: keychainStore, network: network, config: configManager)
                .onChange(of: scenePhase) { _, phase in
                    if case .active = phase {
                        Energy_Stats_Watch_App.delegate.config = configManager
                    }
                }
        }
    }
}
