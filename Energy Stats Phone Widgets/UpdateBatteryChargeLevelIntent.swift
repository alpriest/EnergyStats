//
//  Intents.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 24/09/2023.
//

import AppIntents
import Energy_Stats_Core
import Foundation
import SwiftData
import WidgetKit

@available(iOS 17.0, *)
struct UpdateBatteryChargeLevelIntent: AppIntent {
    static var title: LocalizedStringResource = "Update Storage Battery SOC for the widget"
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
            try await HomeEnergyStateManager.shared.update(config: HomeEnergyStateManagerConfigAdapter(config: configManager))

            WidgetCenter.shared.reloadTimelines(ofKind: "BatteryWidget")

            return .result(value: true)
        } catch {
            return .result(value: false)
        }
    }
}
