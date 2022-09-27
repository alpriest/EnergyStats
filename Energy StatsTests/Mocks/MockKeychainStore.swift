//
//  MockKeychainStore.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

import Foundation
@testable import Energy_Stats

class MockKeychainStore: KeychainStore {
    var username: String?
    var hashedPassword: String?
    var token: String?
    var logoutCalled = false

    override func getUsername() -> String? {
        username
    }

    override func getHashedPassword() -> String? {
        hashedPassword
    }

    override func store(token: String?) throws {
        self.token = token
    }

    override func getToken() -> String? {
        token
    }

    override func store(username: String, hashedPassword: String) throws {
        self.username = username
        self.hashedPassword = hashedPassword
    }

    override func logout() {
        logoutCalled = true
    }
}
