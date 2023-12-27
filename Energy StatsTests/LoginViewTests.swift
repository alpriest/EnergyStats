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
        let sut = LoginView(userManager: UserManager(networking: MockNetworking(), store: MockKeychainStore(), configManager: PreviewConfigManager(), networkCache: InMemoryLoggingNetworkStore()))
        let view = UIHostingController(rootView: sut)

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }

    func test_with_wrong_credentials() async {
        let networking = MockNetworking(throwOnCall: true)
        let userManager = UserManager(networking: networking, store: MockKeychainStore(), configManager: PreviewConfigManager(), networkCache: InMemoryLoggingNetworkStore())
        let sut = LoginView(userManager: userManager)
        let view = UIHostingController(rootView: sut)

        await userManager.login(username: "bob", password: "wrongpassword")

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }
}
