//
//  UserManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import Combine
import Energy_Stats_Core
import Foundation

class UserManager: ObservableObject, HasLoadState {
    private var configManager: ConfigManaging
    private let store: KeychainStoring
    private var cancellables = Set<AnyCancellable>()
    private let networkCache: InMemoryLoggingNetworkStore
    @MainActor @Published var state = LoadState.inactive
    @MainActor @Published var isLoggedIn: Bool = false

    init(store: KeychainStoring, configManager: ConfigManaging, networkCache: InMemoryLoggingNetworkStore) {
        self.store = store
        self.configManager = configManager
        self.networkCache = networkCache

        migrateKeychain()
        self.store.hasCredentials
            .receive(on: RunLoop.main)
            .print()
            .assign(to: \.isLoggedIn, on: self)
            .store(in: &cancellables)
    }

    private func migrateKeychain() {
        let legacyKeychain = KeychainStore(group: "group.com.alpriest.EnergyStats")

        if let token = legacyKeychain.getToken() {
            try? store.store(apiKey: token, notifyObservers: true)
            try? legacyKeychain.store(apiKey: nil, notifyObservers: false)
            print("AWP", "Migrated token to new chain")
        }
    }

    @MainActor
    func login(apiKey: String) async {
        do {
            setState(.active("Loading"))
            if apiKey == "demo" {
                configManager.isDemoUser = true
                configManager.appSettingsPublisher.send(AppSettings.mock())
            }

            try store.store(apiKey: apiKey, notifyObservers: false)
            try await configManager.fetchDevices()
            try await configManager.fetchPowerStationDetail()
            store.updateHasCredentials()
        } catch let error as NetworkError {
            logout()

            switch error {
            case .badCredentials:
                setState(.error(error, String(key: .wrongCredentials)))
            default:
                setState(.error(error, String(key: .couldNotLogin)))
            }
        } catch {
            await MainActor.run {
                setState(.error(error, String(key: .couldNotLogin)))
            }
        }
    }

    @MainActor
    func logout(clearDisplaySettings: Bool = false, clearDeviceSettings: Bool = true) {
        store.logout()
        configManager.logout(clearDisplaySettings: clearDisplaySettings, clearDeviceSettings: clearDeviceSettings)
        networkCache.logout()
        setState(.inactive)
    }
}

extension UserManager {
    static func preview() -> UserManager {
        UserManager(
            store: KeychainStore(),
            configManager: ConfigManager.preview(),
            networkCache: InMemoryLoggingNetworkStore()
        )
    }
}
