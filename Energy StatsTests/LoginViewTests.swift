//
//  LoginViewTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 27/09/2022.
//

@testable import Energy_Stats
import SnapshotTesting
import SwiftUI
import XCTest
import Energy_Stats_Core

@MainActor
final class LoginViewTests: XCTestCase {
    func test_when_user_arrives() {
        let sut = APIKeyLoginView(userManager: UserManager(networking: MockNetworking(), store: MockKeychainStore(), configManager: ConfigManager.preview(), networkCache: InMemoryLoggingNetworkStore()))
        let view = UIHostingController(rootView: sut)

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }

    func test_with_wrong_credentials() async {
        let networking = MockNetworking(throwOnCall: true)
        let userManager = UserManager(networking: networking, store: MockKeychainStore(), configManager: ConfigManager.preview(), networkCache: InMemoryLoggingNetworkStore())
        let sut = APIKeyLoginView(userManager: userManager)
        let view = UIHostingController(rootView: sut)

        await userManager.login(apiKey: "1234")

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }
}
