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
    let delegate = WatchToPhoneSessionDelegate()
    let configManager: WatchConfigManager
    @Environment(\.scenePhase) private var scenePhase

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
                                    urlSession: URLSession.shared,
                                    isDemoUser: { false },
                                    dataCeiling: { .none })
        }
    }()
    
    init() {
        WCSession.default.delegate = delegate
        delegate.activateIfNeeded()

        configManager = WatchConfigManager(keychainStore: keychainStore)
        delegate.config = configManager
    }

    var body: some Scene {
        WindowGroup {
            ContentView(network: network, config: configManager)
        }
    }
}
