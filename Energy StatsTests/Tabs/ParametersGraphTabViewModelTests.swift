//
//  ParametersGraphTabViewModelTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 01/10/2022.
//

@testable import Energy_Stats
import Energy_Stats_Core
import XCTest

@MainActor
final class ParametersGraphTabViewModelTests: XCTestCase {
    var sut: ParametersGraphTabViewModel!
    var networking: Networking!
    var config: MockConfig!

    override func setUp() async throws {
        config = MockConfig()
        networking = MockNetworking()
        let configManager = ConfigManager(networking: networking, config: config)
        sut = ParametersGraphTabViewModel(networking: networking, configManager: configManager) { Date(timeIntervalSince1970: 1669146973) }

        try await configManager.fetchDevices()
    }

    func test_initial_values() {
        XCTAssertEqual(sut.data.count, 0)
        XCTAssertEqual(sut.displayMode, GraphDisplayMode(date: .now, hours: 24))
        XCTAssertEqual(sut.stride, 3)
        XCTAssertEqual(sut.graphVariables, [
            ParameterGraphVariable(RawVariable(name: "Output Power", variable: "generationPower", unit: "kW"), isSelected: true),
            ParameterGraphVariable(RawVariable(name: "Feed-in Power", variable: "feedinPower", unit: "kW"), isSelected: true),
            ParameterGraphVariable(RawVariable(name: "Charge Power", variable: "batChargePower", unit: "kW"), isSelected: true),
            ParameterGraphVariable(RawVariable(name: "Discharge Power", variable: "batDischargePower", unit: "kW"), isSelected: true),
            ParameterGraphVariable(RawVariable(name: "GridConsumption Power", variable: "gridConsumptionPower", unit: "kW"), isSelected: true),
        ])
    }

    func test_fetches_data_on_start() async {
        stubHTTPResponses(with: [.rawSuccess, .reportSuccess, .rawSuccess])

        await sut.load()

        XCTAssertEqual(sut.data.count, 1130)
    }

    func test_filters_when_display_mode_changed() async {
        stubHTTPResponses(with: [.rawSuccess, .reportSuccess, .rawSuccess])
        await sut.load()

        sut.displayMode = GraphDisplayMode(date: .now, hours: 12)

        XCTAssertEqual(sut.stride, 2)
        XCTAssertEqual(sut.data.count, 1130)
    }
}
