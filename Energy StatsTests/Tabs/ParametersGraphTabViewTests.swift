//
//  ParametersGraphTabViewTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 05/11/2022.
//

@testable import Energy_Stats
import Energy_Stats_Core
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class ParametersGraphTabViewTests: XCTestCase {
    func test_when_user_arrives() async throws {
        let networking = MockNetworking(throwOnCall: false, dateProvider: { Date(timeIntervalSince1970: 1664127352) })
        let configManager = ConfigManager(networking: networking, config: MockConfig())
        try await configManager.fetchDevices()

        let sut = ParametersGraphTabView(configManager: configManager, networking: networking) { Date(timeIntervalSince1970: 1664127352) }
        let view = UIHostingController(rootView: sut)

        await sut.viewModel.load()

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }

    func test_with_network_failure() async {
        let networking = MockNetworking(throwOnCall: true)
        let sut = ParametersGraphTabView(configManager: ConfigManager(networking: networking, config: MockConfig()), networking: networking)
        await sut.viewModel.load()
        let view = UIHostingController(rootView: sut)

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }
}
