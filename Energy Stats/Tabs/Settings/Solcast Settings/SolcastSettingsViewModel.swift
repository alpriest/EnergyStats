//
//  SolcastSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/11/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class SolcastSettingsViewModel: ObservableObject {
    private var configManager: ConfigManaging
    @MainActor @Published var resourceId: String = ""
    @MainActor @Published var apiKey: String = ""
    @Published var alertContent: AlertContent?

    init(configManager: ConfigManaging) {
        self.configManager = configManager

        Task { @MainActor in
            resourceId = configManager.solcastResourceId ?? ""
            apiKey = configManager.solcastApiKey ?? ""
        }
    }

    @MainActor
    func save() {
        let config = SolcastSolarForecastingConfigurationAdapter(resourceId: resourceId, apiKey: apiKey)

        Task {
            do {
                let _ = try await Solcast(config: config).fetchForecast()

                configManager.solcastResourceId = resourceId
                configManager.solcastApiKey = apiKey

                alertContent = AlertContent(title: "Success", message: "solcast_settings_saved")
            } catch let NetworkError.invalidConfiguration(reason) {
                alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: reason))
            }
        }
    }
}
