//
//  LoginViewTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 27/09/2022.
//

import XCTest
import SnapshotTesting
@testable import Energy_Stats
import SwiftUI

@MainActor
final class LoginViewTests: XCTestCase {
    func test_when_user_arrives() {
        let sut = LoginView(loginManager: UserManager(networking: MockNetworking(), store: MockKeychainStore(), config: MockConfig()))
        let view = UIHostingController(rootView: sut)

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }

    func test_with_wrong_credentials() async {
        let networking = MockNetworking(throwOnCall: true)
        let userManager = UserManager(networking: networking, store: MockKeychainStore(), config: MockConfig())
        let sut = LoginView(loginManager: userManager)
        let view = UIHostingController(rootView: sut)

        await userManager.login(username: "bob", password: "wrongpassword")

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }
}
