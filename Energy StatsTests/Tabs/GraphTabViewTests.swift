//
//  GraphTabViewTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 05/11/2022.
//

@testable import Energy_Stats
import SnapshotTesting
import SwiftUI
import XCTest
import Energy_Stats_Core

@MainActor
final class GraphTabViewTests: XCTestCase {
    func test_when_user_arrives() async {
        let networking = MockNetworking(throwOnCall: false, dateProvider: { Date(timeIntervalSince1970: 1664127352) })
        let viewModel = GraphTabViewModel(
            networking,
            configManager: ConfigManager(networking: networking, config: MockConfig())
        ) { Date(timeIntervalSince1970: 1664127352) }
        let sut = GraphTabView(viewModel: viewModel)
        let view = UIHostingController(rootView: sut)
        await viewModel.load()
        viewModel.hours = 6

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }

    func test_with_network_failure() async {
        let networking = MockNetworking(throwOnCall: true)
        let viewModel = GraphTabViewModel(MockNetworking(throwOnCall: true),
                                          configManager: ConfigManager(networking: networking, config: MockConfig()))
        await viewModel.load()
        let sut = GraphTabView(viewModel: viewModel)
        let view = UIHostingController(rootView: sut)

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }
}
