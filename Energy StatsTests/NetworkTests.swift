//
//  NetworkTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 25/09/2022.
//

import XCTest
@testable import Energy_Stats
import OHHTTPStubs
import OHHTTPStubsSwift

final class NetworkTests: XCTestCase {
    private var sut: Networking!
    private var keychainStore: MockKeychainStore!

    override func setUp() {
        keychainStore = MockKeychainStore()
        sut = Network(credentials: keychainStore)
    }

    func test_verifyCredentials_does_not_throw_on_success() async throws {
        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let stubPath = OHPathForFile("login-success.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }

        try await sut.verifyCredentials(username: "bob", hashedPassword: "secret")
    }

    func test_verifyCredentials_throws_on_failure() async throws {
        stub(condition: isHost("www.foxesscloud.com")) { _ in
          let stubPath = OHPathForFile("login-failure.json", type(of: self))
          return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }

        do {
            try await sut.verifyCredentials(username: "bob", hashedPassword: "secret")
        } catch NetworkError.badCredentials {
        } catch {
            XCTFail()
        }
    }
}

private class MockKeychainStore: KeychainStore {
    var username: String?
    var password: String?
    var storedToken: String?

    override func getUsername() -> String? {
        username
    }

    override func getPassword() -> String? {
        password
    }

    override func store(token: String?) throws {
        storedToken = token
    }

    override func store(username: String, password: String) throws {
        self.username = username
        self.password = password
    }
}
