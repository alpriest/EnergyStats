//
//  UserManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import Combine
import Foundation

class UserManager: ObservableObject {
    enum State {
        case idle
        case busy
        case error(String)
    }

    private let networking: Networking
    private let configManager: ConfigManager
    private let store: KeychainStore
    private var cancellables = Set<AnyCancellable>()
    @MainActor @Published var state = State.idle
    @MainActor @Published var isLoggedIn: Bool = false

    init(networking: Networking, store: KeychainStore) {
        self.networking = networking
        self.store = store
        self.configManager = ConfigManager(networking: networking)

        self.store.$hasCredentials
            .sink { hasCredentials in
                Task { await MainActor.run { [weak self] in
                    self?.isLoggedIn = hasCredentials
                }}
            }.store(in: &cancellables)
    }

    func getUsername() -> String? {
        store.getUsername()
    }

    func login(username: String, password: String) async {
        do {
            await MainActor.run {
                state = .busy
            }

            guard let hashedPassword = password.md5() else {
                await MainActor.run {
                    state = .error("Could not hash password")
                }
                return
            }
            try await networking.verifyCredentials(username: username, hashedPassword: hashedPassword)
            try store.store(username: username, password: password)
            try await configManager.findDevice()
        } catch let error as NetworkError {
            store.logout()

            await MainActor.run {
                switch error {
                case .invalidConfiguration(let reason):
                    self.state = .error("Invalid configuration - \(reason)")
                case .badCredentials:
                    self.state = .error("Wrong credentials, try again")
                default:
                    self.state = .error("Could not login. Check your internet connnection")
                }
            }
        } catch {
            await MainActor.run {
                self.state = .error("Could not login. Check your internet connnection \(error)")
            }
        }
    }

    func logout() {
        store.logout()
        Config.shared.deviceID = nil
        Config.shared.hasPV = false
        Config.shared.hasBattery = false
    }
}

class ConfigManager {
    let networking: Networking

    struct NoDeviceFoundError: Error {}

    init(networking: Networking) {
        self.networking = networking
    }

    func findDevice() async throws {
        let deviceList = try await networking.fetchDeviceList()

        guard let device = deviceList.devices.first else {
            throw NoDeviceFoundError()
        }

        Config.shared.deviceID = device.deviceID
        Config.shared.hasBattery = device.hasBattery
        Config.shared.hasPV = device.hasPV
    }
}
