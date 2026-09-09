//
//  UserManagerTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

import Combine
@testable import Energy_Stats
@testable import Energy_Stats_Core
import Testing

@Suite(.serialized)
struct UserManagerTests {
    private let sut: UserManager
    private let keychainStore: MockKeychainStore
    private let config: MockConfig

    init() {
        keychainStore = MockKeychainStore()
        config = MockConfig()
        let appSettingsStore = AppSettingsStoreFactory.make()
        appSettingsStore.update(.mock())
        let networking = NetworkService(api: FoxAPIService(apiTokenProvider: { "" }, urlSession: URLSession.shared, tracer: nil))
        let configManager = ConfigManager(networking: networking, config: config, appSettingsStore: appSettingsStore, keychainStore: MockKeychainStore())
        sut = UserManager(store: keychainStore, configManager: configManager)
    }

    @Test
    @MainActor
    func `Is logged in updates from the store`() async {
        keychainStore.updateHasApiKey()
        await propertyOn(sut, keyPath: \.isLoggedIn) { $0 == true }
    }

    @Test
    @MainActor
    func `Logout clears store`() async {
        await sut.logout()

        #expect(keychainStore.logoutCalled)
    }

    @Test
    @MainActor
    func `Logout clears config`() async {
        config.selectedDeviceSN = "device"

        await sut.logout()

        #expect(config.selectedDeviceSN == nil)
    }

    @Test func `Login succeeds`() async {
        let received = ValueReceiver(sut.$state)
        stubHTTPResponses(
            with: [
                .deviceListSuccess,
                .variablesSuccess,
                .batterySuccess,
                .batterySocSuccess,
                .plantListSuccess,
                .plantDetailSuccess
            ]
        )

        await sut.login(apiKey: "bob")
        await propertyOn(keychainStore, keyPath: \.hasApiKey) { $0.value }

        await propertyOn(received, keyPath: \.values) { $0 == [.inactive, .active(.loading)] }
        #expect(keychainStore.token == "bob")
        #expect(config.selectedDeviceSN == "DEVICESN")
        #expect(config.devices != nil)
    }

    @Test func `Login logs out when device list fails`() async {
        let received = ValueReceiver(sut.$state)
        stubHTTPResponses(with: [.tryLaterFailure])

        await sut.login(apiKey: "bob")

        await propertyOn(received, keyPath: \.values) { $0 == [.inactive, .active(.loading), .inactive, .error(NetworkError.tryLater, "Could not login. Check your internet connection")] }
        #expect(keychainStore.logoutCalled)
    }

    @Test func `Login with bad credentials shows error`() async {
        let received = ValueReceiver(sut.$state)
        stubHTTPResponses(with: [.loginFailure])

        await sut.login(apiKey: "bob")

        await propertyOn(received, keyPath: \.values) { $0 == [.inactive, .active(.loading), .inactive, .error(nil, "Wrong credentials, try again")] }
        #expect(keychainStore.token == nil)
        #expect(keychainStore.logoutCalled)
    }

    @Test func `Login while offline shows error`() async {
        let received = ValueReceiver(sut.$state)
        stubOffline()

        await sut.login(apiKey: "bob")
        await propertyOn(received, keyPath: \.values) { $0 == [.inactive, .active(.loading), .inactive, .error(nil, "Could not login. Check your internet connection")] }

        #expect(keychainStore.token == nil)
        #expect(keychainStore.logoutCalled)
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
