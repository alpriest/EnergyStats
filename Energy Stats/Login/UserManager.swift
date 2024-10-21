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
            .sink(receiveValue: { [weak self] newValue in
                Task { @MainActor in
                    self?.isLoggedIn = newValue
                }
            })
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
            await setState(.active("Loading"))
            if apiKey == "demo" {
                configManager.isDemoUser = true
                configManager.appSettingsPublisher.send(AppSettings.mock())
            }

            try store.store(apiKey: apiKey, notifyObservers: false)
            try await configManager.fetchDevices()
            try? await configManager.fetchPowerStationDetail()
            store.updateHasCredentials()
        } catch let error as NetworkError {
            logout()

            switch error {
            case .badCredentials:
                await setState(.error(error, String(key: .wrongCredentials)))
            default:
                await setState(.error(error, String(key: .couldNotLogin)))
            }
        } catch {
            await setState(.error(error, String(key: .couldNotLogin)))
        }
    }

    @MainActor
    func logout(clearDisplaySettings: Bool = false, clearDeviceSettings: Bool = true) {
        if configManager.isDemoUser {
            configManager.logout(clearDisplaySettings: true, clearDeviceSettings: true)
        } else {
            configManager.logout(clearDisplaySettings: clearDisplaySettings, clearDeviceSettings: clearDeviceSettings)
        }
        store.logout()
        networkCache.logout()
        Task {
            await setState(.inactive)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Task { @MainActor in
                self.isLoggedIn = false
            }
        }
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
