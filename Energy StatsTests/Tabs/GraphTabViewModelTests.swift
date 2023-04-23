//
//  GraphTabViewModelTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 01/10/2022.
//

@testable import Energy_Stats
import XCTest
import Energy_Stats_Core

@MainActor
final class GraphTabViewModelTests: XCTestCase {
    var sut: GraphTabViewModel!
    var networking: Networking!
    var config: MockConfig!

    override func setUp() {
        config = MockConfig()
        networking = Network(credentials: MockKeychainStore(), config: config, store: InMemoryLoggingNetworkStore())
        sut = GraphTabViewModel(networking, configManager: ConfigManager(networking: networking, config: config), { Date(timeIntervalSince1970: 1669146973) })
    }

    func test_initial_values() {
        XCTAssertEqual(sut.data.count, 0)
        XCTAssertEqual(sut.displayMode, .today(24))
        XCTAssertEqual(sut.stride, 3)
        XCTAssertEqual(sut.graphVariables, [GraphVariable(.generationPower), GraphVariable(RawVariable.batChargePower), GraphVariable(.batDischargePower), GraphVariable(.feedinPower), GraphVariable(.gridConsumptionPower)])
    }

    func test_fetches_data_on_start() async {
        stubHTTPResponses(with: [.rawSuccess, .reportSuccess, .rawSuccess])

        await sut.load()

        XCTAssertEqual(sut.data.count, 1130)
    }

    func test_filters_when_display_mode_changed() async {
        stubHTTPResponses(with: [.rawSuccess, .reportSuccess, .rawSuccess])
        await sut.load()

        sut.displayMode = .today(12)

        XCTAssertEqual(sut.data.count, 660)
    }
}
