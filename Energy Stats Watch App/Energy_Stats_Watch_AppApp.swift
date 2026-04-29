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
    let keychainStore: KeychainStoring
    let network: Networking
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let isMockDevice = ProcessInfo().arguments.contains("mockDevice")
        let keychainStore: KeychainStoring = isMockDevice ? StubKeychainStore() : KeychainStore()

        self.keychainStore = keychainStore
        self.configManager = WatchConfigManager()
        self.network = isMockDevice
            ? NetworkService.preview()
            : NetworkService.standard(apiTokenProvider: { [configManager] in configManager.apiKey },
                                      urlSession: URLSession.shared,
                                      isDemoUser: { false },
                                      dataCeiling: { .none })

        WCSession.default.delegate = delegate
        delegate.activateIfNeeded()
        delegate.config = configManager
    }

    var body: some Scene {
        WindowGroup {
            ContentView(network: network, config: configManager)
        }
    }
}
