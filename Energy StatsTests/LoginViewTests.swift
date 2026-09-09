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
import Testing

struct LoginViewTests {
    @Test
    @MainActor
    func `When user arrives`() {
        let sut = APIKeyLoginView(userManager: UserManager(store: MockKeychainStore(), configManager: ConfigManager.preview()))
        let view = UIHostingController(rootView: sut)

        assertSnapshot(of: view, as: .image(on: .iPhone13Pro))
    }

    @Test
    @MainActor
    func `With wrong credentials`() async {
        let networking = MockNetworking(callsToThrow: [.openapi_fetchDeviceList])
        let userManager = UserManager(
            store: MockKeychainStore(),
            configManager: ConfigManager.preview(networking: networking)
        )
        let sut = APIKeyLoginView(userManager: userManager)
        let view = UIHostingController(rootView: sut)

        await userManager.login(apiKey: "1234")

        await propertyOn(userManager, keyPath: \.state) { $0 == .inactive }

        assertSnapshot(of: view, as: .image(on: .iPhone13Pro))
    }
}
