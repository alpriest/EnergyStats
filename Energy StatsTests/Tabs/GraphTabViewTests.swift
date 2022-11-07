//
//  GraphTabViewTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 05/11/2022.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import Energy_Stats

@MainActor
final class GraphTabViewTests: XCTestCase {
    func test_when_user_arrives() async {
        let viewModel = GraphTabViewModel(MockNetworking(throwOnCall: false, dateProvider: { Date(timeIntervalSince1970: 1664127352) }), { Date(timeIntervalSince1970: 1664127352) })
        let sut = GraphTabView(viewModel: viewModel)
        let view = UIHostingController(rootView: sut)
        await viewModel.start()
        viewModel.hours = 6

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }

    func test_with_network_failure() async {
        let viewModel = GraphTabViewModel(MockNetworking(throwOnCall: true))
        await viewModel.start()
        let sut = GraphTabView(viewModel: viewModel)
        let view = UIHostingController(rootView: sut)

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }
}
