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

final class LoginViewTests: XCTestCase {
    func test_when_user_arrives() {
        let sut = LoginView(loginManager: UserManager(networking: MockNetworking(), store: MockKeychainStore(), config: MockConfig()))
        let view = UIHostingController(rootView: sut)

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }
}
