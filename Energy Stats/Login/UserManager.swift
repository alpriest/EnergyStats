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
    private let networking: FoxESSNetworking
    private var configManager: ConfigManaging
    private let store: KeychainStoring
    private var cancellables = Set<AnyCancellable>()
    private let networkCache: InMemoryLoggingNetworkStore
    @MainActor @Published var state = LoadState.inactive
    @MainActor @Published var isLoggedIn: Bool = false

    init(networking: FoxESSNetworking, store: KeychainStoring, configManager: ConfigManager, networkCache: InMemoryLoggingNetworkStore) {
        self.networking = networking
        self.store = store
        self.configManager = configManager
        self.networkCache = networkCache

        self.store.hasCredentials
            .assign(to: \.isLoggedIn, on: self)
            .store(in: &cancellables)

        signOutIfFirstRun()
        Task { await migrateSolcast() }
    }

    func signOutIfFirstRun() {
        if configManager.hasRunBefore { return }

        Task { @MainActor in
            logout()
            configManager.hasRunBefore = true
        }
    }

    func migrateSolcast() async {
        if let apiKey = UserDefaults.shared.string(forKey: "solcastApiKey") {
            UserDefaults.shared.removeObject(forKey: "solcastResourceId")
            UserDefaults.shared.removeObject(forKey: "solcastApiKey")

            do {
                let solcast = Solcast()
                let response = try await solcast.fetchSites(apiKey: apiKey)

                configManager.solcastSettings = SolcastSettings(apiKey: apiKey, sites: response.sites.map { SolcastSettings.Site(site: $0) })
            } catch {
                print(error)
            }
        }
    }

    func getUsername() -> String? {
        store.getUsername()
    }

    @MainActor
    func login(username: String, password: String) async {
        do {
            state = .active(String(key: .loading))
            guard let hashedPassword = password.md5() else { throw NSError(domain: "md5", code: 0) }

            if username == "demo", password == "user" {
                configManager.isDemoUser = true
                configManager.appSettings.send(AppSettings.mock())
            } else {
                try await networking.verifyCredentials(username: username, hashedPassword: hashedPassword)
            }

            try store.store(username: username, hashedPassword: hashedPassword, updateHasCredentials: false)
            try await configManager.fetchDevices()
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
        networkCache.logout()
        state = .inactive
    }
}
