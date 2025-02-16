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
    private let solarService: SolarForecastProviding
    @Published var sites: [SolcastSite] = []
    @Published var showSolcastOnParametersPage: Bool = false {
        didSet {
            configManager.showSolcastOnParametersPage = showSolcastOnParametersPage
        }
    }

    init(configManager: ConfigManaging, solarService: @escaping SolarForecastProviding) {
        self.configManager = configManager
        self.solarService = solarService

        Task { @MainActor in
            apiKey = configManager.solcastSettings.apiKey ?? ""
            sites = configManager.solcastSettings.sites
            showSolcastOnParametersPage = configManager.showSolcastOnParametersPage
        }
    }

    @MainActor
    func save() {
        Task { @MainActor in
            do {
                let service = solarService()
                let response = try await service.fetchSites(apiKey: apiKey)
                configManager.solcastSettings = SolcastSettings(apiKey: apiKey, sites: response.sites.map { SolcastSite(site: $0) })
                self.sites = configManager.solcastSettings.sites

                alertContent = AlertContent(title: "Success", message: "solcast_settings_saved")
            } catch let NetworkError.invalidConfiguration(reason) {
                alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: reason))
            } catch {
                alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: error.localizedDescription))
            }
        }
    }

    func removeKey() {
        configManager.solcastSettings = SolcastSettings(apiKey: nil, sites: [])

        Task { @MainActor in
            apiKey = ""
            sites = []
        }
    }
}
