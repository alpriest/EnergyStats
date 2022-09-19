//
//  LoginManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import Combine
import Foundation

class LoginManager: ObservableObject {
    enum State {
        case idle
        case busy
        case error(String)
    }

    private let networking: Networking
    private let store: KeychainStore
    private var cancellables = Set<AnyCancellable>()
    @MainActor @Published var state = State.idle
    @MainActor @Published var isLoggedIn: Bool = false

    init(networking: Networking, store: KeychainStore) {
        self.networking = networking
        self.store = store

        self.store.$hasCredentials
            .sink { hasCredentials in
                Task { await MainActor.run { [weak self] in
                    self?.isLoggedIn = hasCredentials
                }}
            }.store(in: &cancellables)
    }

    func login(username: String, password: String) async {
        do {
            try store.store(username: username, password: password)
            try await networking.verifyCredentials()
        } catch let error as Network.NetworkError {
            store.logout()

            await MainActor.run {
                switch error {
                case .badCredentials:
                    self.state = .error("Wrong credentials, try again")
                case .unknown:
                    self.state = .error("Could not login. Check your internet connnection")
                }
            }
        } catch {
            await MainActor.run {
                self.state = .error("Could not login. Check your internet connnection \(error)")
            }
        }
    }
}
