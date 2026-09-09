//
//  ParametersGraphTabViewTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 05/11/2022.
//

import Combine
@testable import Energy_Stats
import Energy_Stats_Core
import SnapshotTesting
import SwiftUI
import Testing

// Record these on iPhone 16 Pro
struct ParametersGraphTabViewTests {
    @Test
    @MainActor
    func `When user arrives`() async throws {
        let networking = MockNetworking(dateProvider: { Date(timeIntervalSince1970: 1664127352) })
        let appSettingsStore = AppSettingsStoreFactory.make()
        appSettingsStore.update(.mock())
        let configManager = ConfigManager(
            networking: networking,
            config: MockConfig(),
            appSettingsStore: appSettingsStore,
            keychainStore: MockKeychainStore()
        )
        try await configManager.fetchDevices()

        let sut = ParametersGraphTabView(
            configManager: configManager,
            viewModel: ParametersGraphTabViewModel(
                networking: networking,
                configManager: configManager,
                dateProvider: {
                    Date(timeIntervalSince1970: 1664127352)
                },
                solarForecastProvider: { MockSolcast() }
            )
        )
        let view = UIHostingController(rootView: sut.environmentObject(UserManager(store: MockKeychainStore(), configManager: configManager)))

        await sut.viewModel.load()
        await propertyOn(sut.viewModel, keyPath: \.state) { $0 == .inactive }

        assertSnapshot(of: view, as: .image(on: .iPhone13Pro))
    }

    @Test
    @MainActor
    func `With network failure`() async throws {
        let networking = MockNetworking(callsToThrow: [.openapi_fetchHistory])
        let appSettingsStore = AppSettingsStoreFactory.make()
        appSettingsStore.update(.mock())
        let configManager = ConfigManager(
            networking: networking,
            config: MockConfig(),
            appSettingsStore: appSettingsStore,
            keychainStore: MockKeychainStore()
        )
        try await configManager.fetchDevices()
        let sut = ParametersGraphTabView(
            configManager: configManager,
            viewModel: ParametersGraphTabViewModel(
                networking: networking,
                configManager: configManager,
                dateProvider: { Date(timeIntervalSince1970: 1664127352) },
                solarForecastProvider: { MockSolcast() }
            )
        )

        let view = UIHostingController(
            rootView: sut.environmentObject(UserManager(store: MockKeychainStore(), configManager: configManager))
        )

        await sut.viewModel.load()
        await propertyOn(sut.viewModel, keyPath: \.state) { $0 == .error(nil, "") }

        assertSnapshot(of: view, as: .image(on: .iPhone13Pro))
    }
}
