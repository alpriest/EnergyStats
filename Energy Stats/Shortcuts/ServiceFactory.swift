//
//  ServiceFactory.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/10/2024.
//

import AppIntents
import Energy_Stats_Core

enum ServiceFactory {
    static func makeAppIntentInitialisedServices() throws -> AppIntentInitialisedServices {
        let store = KeychainStore()
        let config = UserDefaultsConfig()
        let network = NetworkService.standard(keychainStore: store,
                                              urlSession: URLSession.shared,
                                              isDemoUser: { false },
                                              dataCeiling: { .none })
        let appSettingsStore = AppSettingsStoreFactory.make()
        let configManager = ConfigManager(
            networking: network,
            config: config,
            appSettingsStore: appSettingsStore,
            keychainStore: store
        )
        AppSettingsStoreFactory.update(from: configManager)

        guard let device = configManager.currentDevice.value else {
            throw ConfigManager.NoDeviceFoundError()
        }

        return AppIntentInitialisedServices(
            store: store,
            configManager: configManager,
            network: network,
            device: device
        )
    }
}

struct AppIntentInitialisedServices {
    let store: KeychainStore
    let configManager: ConfigManaging
    let network: Networking
    let device: Device
}
