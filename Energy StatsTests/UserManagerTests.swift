//
//  UserManagerTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

import Combine
@testable import Energy_Stats
import XCTest
@testable import Energy_Stats_Core

final class UserManagerTests: XCTestCase {
    private var sut: UserManager!
    private var keychainStore: MockKeychainStore!
    private var networking: Networking!
    private var config: MockConfig!
    private var configManager: PreviewConfigManager!

    override func setUp() {
        keychainStore = MockKeychainStore()
        config = MockConfig()
        let cache = InMemoryLoggingNetworkStore()
        networking = NetworkService(api: FoxAPIService(credentials: keychainStore,  store: cache))
        configManager = PreviewConfigManager(networking: networking, config: config, appSettingsPublisher: CurrentValueSubject<AppSettings, Never>(AppSettings.mock()))
        sut = UserManager(networking: networking, store: keychainStore, configManager: configManager, networkCache: cache)
    }

    @MainActor
    func test_isLoggedIn_SetsOnInitialisation() {
        let expectation = self.expectation(description: #function)
        keychainStore.updateHasCredentials(value: true)

        sut.$isLoggedIn
            .receive(subscriber: Subscribers.Sink(receiveCompletion: { _ in
            }, receiveValue: { value in
                if value {
                    expectation.fulfill()
                }
            }))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(sut.isLoggedIn)
    }

    @MainActor
    func test_logout_clears_store() {
        sut.logout()

        XCTAssertTrue(keychainStore.logoutCalled)
    }

    @MainActor
    func test_logout_clears_config() {
        config.selectedDeviceID = "device"

        sut.logout()

        XCTAssertNil(config.selectedDeviceID)
    }

    func test_login_success() async {
        let received = ValueReceiver(sut.$state)
        stubHTTPResponses(with: [.loginSuccess, .deviceListSuccess, .firmwareVersionSuccess, .variablesSuccess, .batterySuccess, .batterySocSuccess])

        await sut.login(apiKey: "bob")

        XCTAssertEqual(received.values, [.inactive, .active("Loading...")])
        XCTAssertEqual(keychainStore.token, "bob")
        XCTAssertEqual(keychainStore.hashedPassword, "password".md5()!)
        XCTAssertEqual(config.selectedDeviceID, "12345678-0000-0000-1234-aaaabbbbcccc")
        XCTAssertNotNil(config.devices)
    }

    func test_login_performs_logout_when_devicelist_fails() async {
        let received = ValueReceiver(sut.$state)
        stubHTTPResponses(with: [.loginSuccess, .tryLaterFailure])

        await sut.login(apiKey: "bob")

        XCTAssertEqual(received.values, [.inactive, .active("Loading..."), .inactive, .error(nil, "Could not login. Check your internet connection")])
        XCTAssertTrue(keychainStore.logoutCalled)
    }

    func test_login_with_bad_credentials_shows_error() async {
        let received = ValueReceiver(sut.$state)
        stubHTTPResponses(with: [.loginFailure])

        await sut.login(apiKey: "bob")

        XCTAssertEqual(received.values, [.inactive, .active("Loading..."), .inactive, .error(nil, "Wrong credentials, try again")])
        XCTAssertNil(keychainStore.token)
        XCTAssertNil(keychainStore.hashedPassword)
        XCTAssertTrue(keychainStore.logoutCalled)
    }

    func test_login_when_offline_shows_error() async {
        let received = ValueReceiver(sut.$state)
        stubOffline()

        await sut.login(apiKey: "bob")

        XCTAssertEqual(received.values, [.inactive, .active("Loading..."), .inactive, .error(nil, "Could not login. Check your internet connection")])
        XCTAssertNil(keychainStore.token)
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
