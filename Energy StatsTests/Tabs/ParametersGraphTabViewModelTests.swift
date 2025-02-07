//
//  ParametersGraphTabViewModelTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 01/10/2022.
//

import Combine
@testable import Energy_Stats
import Energy_Stats_Core
import XCTest

final class ParametersGraphTabViewModelTests: XCTestCase {
    var sut: ParametersGraphTabViewModel!
    var networking: Networking!
    var config: MockConfig!

    override func setUp() async throws {
        config = MockConfig()
        networking = MockNetworking(dateProvider: { Date(timeIntervalSince1970: 1669146973) })
        let configManager = ConfigManager(
            networking: networking,
            config: config,
            appSettingsPublisher: CurrentValueSubject<AppSettings, Never>(AppSettings.mock()),
            keychainStore: MockKeychainStore()
        )
        sut = ParametersGraphTabViewModel(
            networking: networking,
            configManager: configManager,
            dateProvider: { Date(timeIntervalSince1970: 1669146973) },
            solarForecastProvider: { MockSolcast() }
        )

        try await configManager.fetchDevices()
    }

    func test_initial_values() {
        XCTAssertEqual(sut.data.count, 0)
        XCTAssertEqual(sut.displayMode, ParametersGraphDisplayMode(date: Date(timeIntervalSince1970: 1669146973), hours: 24))
        XCTAssertEqual(sut.stride, 3)
    }

    func test_fetches_data_on_load() async throws {
        await sut.load()

        let key = try XCTUnwrap(sut.data.keys.first)
        let kwhData = sut.data[key]!
        let types = Set(kwhData.values.map { $0.type.name })
        let feedinPowerData = kwhData.values.filter { $0.type.variable == "feedinPower" }

        XCTAssertEqual(key, "kW")
        XCTAssertEqual(sut.data.count, 1)
        XCTAssertEqual(types.count, 5)
        XCTAssertEqual(feedinPowerData.count, 108)
    }

    func test_filters_when_display_mode_changed() async throws {
        await sut.load()

        sut.displayMode = ParametersGraphDisplayMode(date: Date(timeIntervalSince1970: 1669146973), hours: 12)

        let key = try XCTUnwrap(sut.data.keys.first)
        let kwhData = sut.data[key]!
        let feedinPowerData = kwhData.values.filter { $0.type.variable == "feedinPower" }

        XCTAssertEqual(sut.stride, 2)
        XCTAssertEqual(feedinPowerData.count, 13)
    }
}
