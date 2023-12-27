//
//  Energy_Stats_Watch_AppApp.swift
//  Energy Stats Watch App Watch App
//
//  Created by Alistair Priest on 03/04/2023.
//

import SwiftUI
import Energy_Stats_Core
@main
struct Energy_Stats_Watch_App_Watch_AppApp: App {
    var body: some Scene {
        let keychainStore = KeychainStore()
        let config = UserDefaultsConfig()
        let network = NetworkFacade(network: Network(credentials: keychainStore, config: config),
                                    config: config)
        let configManager = ConfigManager(networking: network, config: config)

        WindowGroup {
            ContentView(
                viewModel: ContentViewModel(network, configManager: configManager)
            )
        }
    }
}
