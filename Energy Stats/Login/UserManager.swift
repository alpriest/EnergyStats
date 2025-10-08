//
//  UserManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import Combine
import Energy_Stats_Core
import Foundation
import SwiftUI

class UserManager: ObservableObject, HasLoadState {
    private var configManager: ConfigManaging
    private let store: KeychainStoring
    private var cancellables = Set<AnyCancellable>()
    @MainActor @Published var state = LoadState.inactive
    @MainActor @Published var isLoggedIn: Bool?

    init(store: KeychainStoring, configManager: ConfigManaging) {
        self.store = store
        self.configManager = configManager

        migrateKeychain()
        self.store.hasCredentials
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] newValue in
                Task { @MainActor in
                    withAnimation {
                        self?.isLoggedIn = newValue
                    }
                }
            })
            .store(in: &cancellables)
    }

    private func migrateKeychain() {
        let legacyKeychain = KeychainStore(group: "group.com.alpriest.EnergyStats")

        if let token = try? legacyKeychain.getToken() {
            try? store.store(apiKey: token, notifyObservers: true)
            try? legacyKeychain.store(apiKey: nil, notifyObservers: false)
            print("AWP", "Migrated token to new chain")
        }
    }

    @MainActor
    func login(apiKey: String) async {
        do {
            await setState(.active(.loading))
            if apiKey == "demo" {
                configManager.isDemoUser = true
                configManager.appSettingsPublisher.send(AppSettings.mock())
            }
            
            try store.store(apiKey: apiKey, notifyObservers: false)
            try await configManager.fetchDevices()
            try? await configManager.fetchPowerStationDetail()
            store.updateHasCredentials()
        } catch let error as NetworkError {
            await logout()

            switch error {
            case .badCredentials:
                if !apiKey.isValidAPIKey {
                    await setState(.error(error, String(key: .invalidApiKeyFormat) + "\n\n" + String(key: .what_is_api_key_3)))
                    return
                }

                await setState(.error(error, String(key: .wrongCredentials)))
            default:
                await setState(.error(error, String(key: .couldNotLogin)))
            }
        } catch {
            await setState(.error(error, String(key: .couldNotLogin)))
        }
    }

    @MainActor
    func logout(clearDisplaySettings: Bool = false, clearDeviceSettings: Bool = true) async {
        if configManager.isDemoUser {
            configManager.logout(clearDisplaySettings: true, clearDeviceSettings: true)
        } else {
            configManager.logout(clearDisplaySettings: clearDisplaySettings, clearDeviceSettings: clearDeviceSettings)
        }
        store.logout()
        await setState(.inactive)

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
            configManager: ConfigManager.preview()
        )
    }
}

private extension String {
    var isValidAPIKey: Bool {
        let pattern = #"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }
}
