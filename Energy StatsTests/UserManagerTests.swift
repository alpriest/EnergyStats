//
//  UserManagerTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

import Combine
@testable import Energy_Stats
@testable import Energy_Stats_Core
import XCTest

final class UserManagerTests: XCTestCase {
    private var sut: UserManager!
    private var keychainStore: MockKeychainStore!
    private var networking: Networking!
    private var config: MockConfig!
    private var configManager: ConfigManager!

    override func setUp() {
        keychainStore = MockKeychainStore()
        config = MockConfig()
        networking = NetworkService(api: FoxAPIService(credentials: keychainStore, urlSession: URLSession.shared))
        configManager = ConfigManager(networking: networking, config: config, appSettingsPublisher: CurrentValueSubject<AppSettings, Never>(AppSettings.mock()), keychainStore: MockKeychainStore())
        sut = UserManager(store: keychainStore, configManager: configManager)
    }

    @MainActor
    func test_isLoggedIn_SetsOnInitialisation() {
        let expectation = self.expectation(description: #function)
        keychainStore.updateHasApiKey()

        sut.$isLoggedIn
            .receive(subscriber: Subscribers.Sink(receiveCompletion: { _ in
            }, receiveValue: { value in
                if value == true {
                    expectation.fulfill()
                }
            }))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.isLoggedIn, true)
    }

    @MainActor
    func test_logout_clears_store() async {
        await sut.logout()

        XCTAssertTrue(keychainStore.logoutCalled)
    }

    @MainActor
    func test_logout_clears_config() async {
        config.selectedDeviceSN = "device"

        await sut.logout()

        XCTAssertNil(config.selectedDeviceSN)
    }

    func test_login_success() async {
        let received = ValueReceiver(sut.$state)
        stubHTTPResponses(with: [.deviceListSuccess, .variablesSuccess, .batterySuccess, .batterySocSuccess, .plantListSuccess, .plantDetailSuccess])

        await sut.login(apiKey: "bob")
        await propertyOn(keychainStore, keyPath: \.hasApiKey) { $0.value }

        await propertyOn(received, keyPath: \.values) { $0 == [.inactive, .active(.loading)] }
        XCTAssertEqual(keychainStore.token, "bob")
        XCTAssertEqual(config.selectedDeviceSN, "DEVICESN")
        XCTAssertNotNil(config.devices)
    }

    func test_login_performs_logout_when_devicelist_fails() async {
        let received = ValueReceiver(sut.$state)
        stubHTTPResponses(with: [.tryLaterFailure])

        await sut.login(apiKey: "bob")

        await propertyOn(received, keyPath: \.values) { $0 == [.inactive, .active(.loading), .inactive, .error(NetworkError.tryLater, "Could not login. Check your internet connection")] }
        XCTAssertTrue(keychainStore.logoutCalled)
    }

    func test_login_with_bad_credentials_shows_error() async {
        let received = ValueReceiver(sut.$state)
        stubHTTPResponses(with: [.loginFailure])

        await sut.login(apiKey: "bob")

        await propertyOn(received, keyPath: \.values) { $0 == [.inactive, .active(.loading), .inactive, .error(nil, "Wrong credentials, try again")] }
        XCTAssertNil(keychainStore.token)
        XCTAssertTrue(keychainStore.logoutCalled)
    }

    func test_login_when_offline_shows_error() async {
        let received = ValueReceiver(sut.$state)
        stubOffline()

        await sut.login(apiKey: "bob")
        await propertyOn(received, keyPath: \.values) { $0 == [.inactive, .active(.loading), .inactive, .error(nil, "Could not login. Check your internet connection")] }

        XCTAssertNil(keychainStore.token)
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
                receiveValue: {
                    self.values.append($0)
                }
            )
    }
}
