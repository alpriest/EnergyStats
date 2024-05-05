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

    var body: some Scene {
        let keychainStore = KeychainStore()
        let network = NetworkService.standard(keychainStore: keychainStore,
                                              isDemoUser: { false },
                                              dataCeiling: { .none })
        let configManager = WatchConfigManager()

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

class EnergyStatsWatchAppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidBecomeActive() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = Energy_Stats_Watch_App.delegate
            session.activate()
        }
    }
}

class WatchSessionDelegate: NSObject, WCSessionDelegate {
    var config: WatchConfigManaging?

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        print("AWP", "Received data")
        if let batteryCapacity = userInfo["batteryCapacity"] as? String {
            print("AWP", "Setting battery capacity", batteryCapacity)
            config?.batteryCapacity = batteryCapacity
        }
    }
}
