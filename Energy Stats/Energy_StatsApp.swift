//
//  Energy_StatsApp.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import SwiftUI

@main
struct Energy_StatsApp: App {
    var body: some Scene {
        let keychainStore = KeychainStore()
        let config = UserDefaultsConfig()
        let network = NetworkFacade(network: Network(credentials: keychainStore, config: config),
                                    config: config)
        let loginManager = UserManager(networking: network, store: keychainStore, config: config)

        return WindowGroup {
            if isRunningTests() {
                Text("Tests")
            } else {
                ContentView(
                    loginManager: loginManager,
                    network: network,
                    config: config
                )
            }
        }
    }

    func isRunningTests() -> Bool {
        CommandLine.arguments.contains("-TESTING=1")
    }
}
