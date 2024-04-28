//
//  Energy_Stats_Watch_AppApp.swift
//  Energy Stats Watch App Watch App
//
//  Created by Alistair Priest on 27/04/2024.
//

import Energy_Stats_Core
import SwiftUI

@main
struct Energy_Stats_Watch_App: App {
    var body: some Scene {
        let config = UserDefaultsConfig()
        let keychainStore = KeychainStore()
        let network = NetworkService.standard(keychainStore: keychainStore, config: config)

        WindowGroup {
            ContentView(deviceSN: "66BH3720228D004", token: keychainStore.getToken(), network: network)
        }
    }
}
