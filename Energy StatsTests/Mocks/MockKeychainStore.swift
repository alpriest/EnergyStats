//
//  MockKeychainStore.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

@testable import Energy_Stats
import Energy_Stats_Core
import Foundation
import Combine

class MockKeychainStore: KeychainStoring {
    var username: String?
    var hashedPassword: String?
    var token: String?
    var logoutCalled = false

    func getUsername() -> String? {
        username
    }

    func getHashedPassword() -> String? {
        hashedPassword
    }

    func store(token: String?) throws {
        self.token = token
    }

    func getToken() -> String? {
        token
    }

    func store(username: String, hashedPassword: String, updateHasCredentials: Bool = true) throws {
        self.username = username
        self.hashedPassword = hashedPassword
    }

    func logout() {
        logoutCalled = true
    }

    func updateHasCredentials() {}

    let hasCredentialsSubject = CurrentValueSubject<Bool, Never>(false)
    let hasCredentials: AnyPublisher<Bool, Never>

    init() {
        hasCredentials = hasCredentialsSubject.eraseToAnyPublisher()
    }

    func updateHasCredentials(value: Bool) {
        hasCredentialsSubject.send(value)
    }
}
