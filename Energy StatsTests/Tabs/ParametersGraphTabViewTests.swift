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
        let viewModel = ParametersGraphTabViewModel(
            networking: networking,
            configManager: configManager
        ) { Date(timeIntervalSince1970: 1664127352) }

        let sut = ParametersGraphTabView(viewModel: viewModel)
        let view = UIHostingController(rootView: sut)

        await viewModel.load()

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }

    func test_with_network_failure() async {
        let networking = MockNetworking(throwOnCall: true)
        let viewModel = ParametersGraphTabViewModel(
            networking: MockNetworking(throwOnCall: true),
            configManager: ConfigManager(networking: networking, config: MockConfig())
        )
        await viewModel.load()
        let sut = ParametersGraphTabView(viewModel: viewModel)
        let view = UIHostingController(rootView: sut)

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }
}
