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
struct UpdateTodayStatsIntent: AppIntent {
    static var title: LocalizedStringResource = "Update Today Stats for the widget"
    static var authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some ReturnsValue<Bool> {
        do {
            let config = UserDefaultsConfig()
            let keychainStore = KeychainStore()
            let appSettingsPublisher = AppSettingsPublisherFactory.make(from: config)
            let network = NetworkService.standard(keychainStore: keychainStore,
                                                  isDemoUser: {
                                                      false
                                                  },
                                                  dataCeiling: { .none })

            let configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher, keychainStore: keychainStore)
            try await HomeEnergyStateManager.shared.updateTodayStatsState(config: HomeEnergyStateManagerConfigAdapter(config: configManager))

            WidgetCenter.shared.reloadTimelines(ofKind: "TodayStatsWidget")

            return .result(value: true)
        } catch {
            return .result(value: false)
        }
    }
}

class foo {
    func aa() async {
        _ = try? await UpdateTodayStatsIntent().perform()
    }
}
