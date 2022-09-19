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
    @Published var state = State.idle

    init(networking: Networking, store: KeychainStore) {
        self.networking = networking
        self.store = store

        self.store.$hasCredentials.sink { [weak self] hasCredentials in
            self?.isLoggedIn = hasCredentials
        }.store(in: &cancellables)
    }

    @Published var isLoggedIn: Bool = false

    func login(username: String, password: String) {
        Task {
            do {
                try await networking.verifyCredentials()
                try store.store(username: username, password: password)
            } catch let error as Network.NetworkError {
                switch error {
                case .badCredentials:
                    self.state = .error("Wrong credentials, try again")
                case .unknown:
                    self.state = .error("Could not login. Check your internet connnection")
                }
            }
        }
    }
}
