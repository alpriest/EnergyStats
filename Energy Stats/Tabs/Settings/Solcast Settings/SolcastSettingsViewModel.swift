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
    @MainActor @Published var apiKey: String = ""
    @Published var alertContent: AlertContent?

    init(configManager: ConfigManaging) {
        self.configManager = configManager

        Task { @MainActor in
            apiKey = configManager.solcastSettings.apiKey ?? ""
        }
    }

    @MainActor
    func save() {
        Task {
            do {
                let service = SolcastCache(service: { Solcast() }) // TODO: INJECT
                let response = try await service.fetchSites(apiKey: apiKey)
                configManager.solcastSettings = SolcastSettings(apiKey: apiKey, sites: response.sites.map { SolcastSettings.Site(site: $0) })

                alertContent = AlertContent(title: "Success", message: "solcast_settings_saved")
            } catch let NetworkError.invalidConfiguration(reason) {
                alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: reason))
            }
        }
    }
}
