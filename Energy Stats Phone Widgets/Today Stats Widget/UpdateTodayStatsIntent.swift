//
//  UpdateTodayStatsIntent.swift
//  Energy Stats
//
//  Created by Alistair Priest on 11/10/2024.
//

import AppIntents
import Energy_Stats_Core
import Foundation
import SwiftData
import WidgetKit

@available(iOS 17.0, *)
struct UpdateStatsIntent: AppIntent {
    static var title: LocalizedStringResource = "Update Stats for the widget"
    static var authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some ReturnsValue<Bool> {
        do {
            let config = UserDefaultsConfig()
            let keychainStore = KeychainStore()
            let appSettingsPublisher = AppSettingsPublisherFactory.make()
            let network = NetworkService.standard(keychainStore: keychainStore,
                                                  urlSession: URLSession.shared,
                                                  isDemoUser: {
                                                      false
                                                  },
                                                  dataCeiling: { .none })

            let configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher, keychainStore: keychainStore)
            AppSettingsPublisherFactory.update(from: configManager)
            let configAdapter = HomeEnergyStateManagerConfigAdapter(config: configManager, keychainStore: keychainStore)
            try await HomeEnergyStateManager.shared.updateTodayStatsState(config: configAdapter)
            try await HomeEnergyStateManager.shared.updateGenerationStatsState(config: configAdapter)
            try await HomeEnergyStateManager.shared.updateBatteryState(config: HomeEnergyStateManagerConfigAdapter(config: configManager, keychainStore: keychainStore))

            WidgetCenter.shared.reloadAllTimelines()

            return .result(value: true)
        } catch {
            return .result(value: false)
        }
    }
}

class foo {
    func aa() async {
        _ = try? await UpdateStatsIntent().perform()
    }
}
