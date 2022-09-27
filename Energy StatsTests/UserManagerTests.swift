//
//  UserManagerTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

import Combine
@testable import Energy_Stats
import XCTest

@MainActor
final class UserManagerTests: XCTestCase {
    private var sut: UserManager!
    private var keychainStore: MockKeychainStore!
    private var networking: MockNetworking!
    private var config: MockConfig!

    override func setUp() {
        keychainStore = MockKeychainStore()
        networking = MockNetworking()
        config = MockConfig()
        sut = UserManager(networking: networking, store: keychainStore, config: config)
    }

    func test_IsLoggedIn_SetsOnInitialisation() {
        var expectation: XCTestExpectation? = self.expectation(description: #function)
        keychainStore.hasCredentials = true

        sut.$isLoggedIn
            .receive(subscriber: Subscribers.Sink(receiveCompletion: { _ in
            }, receiveValue: { value in
                if value {
                    expectation?.fulfill()
                    expectation = nil
                }
            }))

        wait(for: [expectation!], timeout: 1.0)
        XCTAssertTrue(sut.isLoggedIn)
    }

    func test_returns_username_from_keychain() {
        keychainStore.username = "bob"

        XCTAssertEqual(sut.getUsername(), "bob")
    }

    func test_logout_clears_store() {
        sut.logout()

        XCTAssertTrue(keychainStore.logoutCalled)
    }

    func test_logout_clears_config() {
        config.deviceID = "device"
        config.hasPV = true
        config.hasBattery = true

        sut.logout()

        XCTAssertNil(config.deviceID)
        XCTAssertFalse(config.hasPV)
        XCTAssertFalse(config.hasBattery)
    }

    func test_login_success() async {
        let received = ValueReceiver(sut.$state)
        stubHTTPResponses(with: [.loginSuccess, .deviceListSuccess])

        await sut.login(username: "bob", password: "password")

        XCTAssertEqual(received.values, [.idle, .busy])
        XCTAssertEqual(keychainStore.username, "bob")
        XCTAssertEqual(keychainStore.hashedPassword, "password".md5()!)
    }

    func test_login_performs_logout_when_devicelist_fails() async {
        let received = ValueReceiver(sut.$state)
        stubHTTPResponses(with: [.loginSuccess, .tryLaterFailure])

        await sut.login(username: "bob", password: "password")

        XCTAssertEqual(received.values, [.idle, .busy, .error("Could not login. Check your internet connnection")])
        XCTAssertTrue(keychainStore.logoutCalled)
    }

    func test_login_with_bad_credentials_shows_error() async {
        let received = ValueReceiver(sut.$state)
        stubHTTPResponses(with: [.loginFailure])

        await sut.login(username: "bob", password: "wrongpassword")

        XCTAssertEqual(received.values, [.idle, .busy, .error("Wrong credentials, try again")])
        XCTAssertNil(keychainStore.username)
        XCTAssertNil(keychainStore.hashedPassword)
        XCTAssertTrue(keychainStore.logoutCalled)
    }

    func test_login_when_offline_shows_error() async {
        let received = ValueReceiver(sut.$state)
        stubOffline()

        await sut.login(username: "bob", password: "wrongpassword")

        XCTAssertEqual(received.values, [.idle, .busy, .error("Could not login. Check your internet connnection")])
        XCTAssertNil(keychainStore.username)
        XCTAssertNil(keychainStore.hashedPassword)
        XCTAssertTrue(keychainStore.logoutCalled)
    }
}

class ValueReceiver<T> {
    var values: [T] = []
    var cancellable: AnyCancellable?

    init(_ publisher: Published<T>.Publisher) {
        cancellable = publisher
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { self.values.append($0) }
            )
    }
}
