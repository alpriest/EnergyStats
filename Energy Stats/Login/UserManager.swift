//
//  UserManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import Combine
import Energy_Stats_Core
import Foundation

class UserManager: ObservableObject {
    private let networking: Networking
    private let configManager: ConfigManager
    private let store: KeychainStoring
    private var cancellables = Set<AnyCancellable>()
    @MainActor @Published var state = LoadState.inactive
    @MainActor @Published var isLoggedIn: Bool = false

    init(networking: Networking, store: KeychainStoring, configManager: ConfigManager) {
        self.networking = networking
        self.store = store
        self.configManager = configManager

        self.store.hasCredentials
            .sink { hasCredentials in
                Task { await MainActor.run { [weak self] in
                    self?.isLoggedIn = hasCredentials
                }}
            }.store(in: &cancellables)
    }

    func getUsername() -> String? {
        store.getUsername()
    }

    @MainActor
    func login(username: String, password: String) async {
        if username == "demo", password == "user" {
            configManager.isDemoUser = true
            do {
                try store.store(username: "demo", hashedPassword: "user")
            } catch let error {
                state = .error(error, String(key: .couldNotLogin))
            }
            return
        }

        do {
            state = .active(String(key: .loading))

            guard let hashedPassword = password.md5() else { throw NSError(domain: "md5", code: 0) }

            try await networking.verifyCredentials(username: username, hashedPassword: hashedPassword)
            try store.store(username: username, hashedPassword: hashedPassword, updateHasCredentials: false)
            try await configManager.findDevices()
            try await configManager.fetchFirmwareVersions()
            try await configManager.fetchVariables()
            store.updateHasCredentials()
        } catch let error as NetworkError {
            logout()

            switch error {
            case .badCredentials:
                self.state = .error(error, String(key: .wrongCredentials))
            default:
                self.state = .error(error, String(key: .couldNotLogin))
            }
        } catch {
            await MainActor.run {
                self.state = .error(error, String(key: .couldNotLogin))
            }
        }
    }

    @MainActor
    func logout() {
        store.logout()
        configManager.logout()
        state = .inactive
    }
}
