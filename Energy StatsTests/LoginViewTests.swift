//
//  LoginViewTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 27/09/2022.
//

@testable import Energy_Stats
import Energy_Stats_Core
import SnapshotTesting
import SwiftUI
import XCTest

final class LoginViewTests: XCTestCase {
    @MainActor
    func test_when_user_arrives() {
        let sut = APIKeyLoginView(userManager: UserManager(store: MockKeychainStore(), configManager: ConfigManager.preview(), networkCache: InMemoryLoggingNetworkStore()))
        let view = UIHostingController(rootView: sut)

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }

    @MainActor
    func test_with_wrong_credentials() async {
        let networking = MockNetworking(callsToThrow: [.openapi_fetchDeviceList])
        let userManager = UserManager(
            store: MockKeychainStore(),
            configManager: ConfigManager.preview(networking: networking),
            networkCache: InMemoryLoggingNetworkStore()
        )
        let sut = APIKeyLoginView(userManager: userManager)
        let view = UIHostingController(rootView: sut)

        await userManager.login(apiKey: "1234")

        await propertyOn(userManager, keyPath: \.state) { $0 == .inactive }

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }
}
