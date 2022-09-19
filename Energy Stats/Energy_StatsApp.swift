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
        let network = Network(credentials: keychainStore)
        let loginManager = LoginManager(networking: network, store: keychainStore)

        return WindowGroup {
            ContentView(
                loginManager: loginManager,
                network: network,
                credentials: keychainStore
            )
        }
    }
}
