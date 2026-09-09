//
//  ParametersGraphTabViewModelTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 01/10/2022.
//

import Combine
@testable import Energy_Stats
import Energy_Stats_Core
import Testing

struct ParametersGraphTabViewModelTests {
    let sut: ParametersGraphTabViewModel

    init() async throws {
        let config = MockConfig()
        let networking = MockNetworking(dateProvider: { Date(timeIntervalSince1970: 1669146973) })
        let appSettingsStore = AppSettingsStoreFactory.make()
        appSettingsStore.update(.mock())
        let configManager = ConfigManager(
            networking: networking,
            config: config,
            appSettingsStore: appSettingsStore,
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

    @Test func `Initial values`() {
        #expect(sut.data.isEmpty)
        #expect(sut.displayMode == ParametersGraphDisplayMode(date: Date(timeIntervalSince1970: 1669146973), hours: 24))
        #expect(sut.stride == 3)
    }

    @Test func `Fetches data on load`() async throws {
        await sut.load()

        let key = try #require(sut.data.keys.first)
        let kwhData = try #require(sut.data[key])
        let types = Set(kwhData.values.map { $0.type.name })
        let feedinPowerData = kwhData.values.filter { $0.type.variable == "feedinPower" }

        #expect(key == "kW")
        #expect(sut.data.count == 1)
        #expect(types.count == 5)
        #expect(feedinPowerData.count == 108)
    }

    @Test func `Filters when display mode changes`() async throws {
        await sut.load()

        sut.displayMode = ParametersGraphDisplayMode(date: Date(timeIntervalSince1970: 1669146973), hours: 12)

        let key = try #require(sut.data.keys.first)
        let kwhData = try #require(sut.data[key])
        let feedinPowerData = kwhData.values.filter { $0.type.variable == "feedinPower" }

        #expect(sut.stride == 2)
        #expect(feedinPowerData.count == 13)
    }
}
