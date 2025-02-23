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
import XCTest

// Record these on iPhone 16 Pro
final class ParametersGraphTabViewTests: XCTestCase {
    @MainActor
    func test_when_user_arrives() async throws {
        let networking = MockNetworking(dateProvider: { Date(timeIntervalSince1970: 1664127352) })
        let configManager = ConfigManager(
            networking: networking,
            config: MockConfig(),
            appSettingsPublisher: CurrentValueSubject<AppSettings, Never>(AppSettings.mock()),
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
        let view = UIHostingController(rootView: sut.environmentObject(UserManager(store: MockKeychainStore(), configManager: configManager, networkCache: InMemoryLoggingNetworkStore())))

        await sut.viewModel.load()
        await propertyOn(sut.viewModel, keyPath: \.state) { $0 == .inactive }

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }

    @MainActor
    func test_with_network_failure() async throws {
        let networking = MockNetworking(callsToThrow: [.openapi_fetchHistory])
        let configManager = ConfigManager(
            networking: networking,
            config: MockConfig(),
            appSettingsPublisher: CurrentValueSubject<AppSettings, Never>(AppSettings.mock()),
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

        let view = UIHostingController(rootView: sut.environmentObject(UserManager(store: MockKeychainStore(), configManager: configManager, networkCache: InMemoryLoggingNetworkStore())))

        await sut.viewModel.load()
        await propertyOn(sut.viewModel, keyPath: \.state) { $0 == .error(nil, "") }

        assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))
    }
}
