//
//  UpdateBatteryChargeLevelIntent.swift
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
            let network = NetworkService.standard(keychainStore: keychainStore,
                                                  urlSession: URLSession.shared,
                                                  isDemoUser: {
                                                      false
                                                  },
                                                  dataCeiling: { .none })

            let appSettingsPublisher = AppSettingsPublisherFactory.make()
            let configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher, keychainStore: keychainStore)
            AppSettingsPublisherFactory.update(from: configManager)
            try await HomeEnergyStateManager.shared.updateBatteryState(config: HomeEnergyStateManagerConfigAdapter(config: configManager, keychainStore: keychainStore))

            WidgetCenter.shared.reloadTimelines(ofKind: "BatteryCircularWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "BatteryCornerWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "BatteryRectangularWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "BatteryStatusWidget")

            return .result(value: true)
        } catch {
            return .result(value: false)
        }
    }
}
