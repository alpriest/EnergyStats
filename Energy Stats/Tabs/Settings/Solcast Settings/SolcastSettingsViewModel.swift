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
    @MainActor @Published var site1ResourceId: String = ""
    @MainActor @Published var site1ApiKey: String = ""
    @MainActor @Published var site1Name: String = ""
    @MainActor @Published var site2ResourceId: String = ""
    @MainActor @Published var site2ApiKey: String = ""
    @MainActor @Published var site2Name: String = ""
    @Published var alertContent: AlertContent?

    init(configManager: ConfigManaging) {
        self.configManager = configManager

        Task { @MainActor in
            if let site = configManager.solcastSettings.sites[safe: 0] {
                site1ResourceId = site.resourceId
                site1ApiKey = site.apiKey
                site1Name = site.name ?? ""
            }

            if let site = configManager.solcastSettings.sites[safe: 1] {
                site2ResourceId = site.resourceId
                site2ApiKey = site.apiKey
                site2Name = site.name ?? ""
            }
        }
    }

    @MainActor
    func save() {
        Task {
            let sites = makeSites()
            configManager.solcastSettings = SolcastSettings(sites: sites)

            try await sites.asyncForEach { site in
                guard site.resourceId != "" && site.apiKey != "" else { return }

                do {
                    let _ = try await Solcast().fetchForecast(for: site)

                    alertContent = AlertContent(title: "Success", message: "solcast_settings_saved")
                } catch let NetworkError.invalidConfiguration(reason) {
                    alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: site.resourceId + " " + reason))
                }
            }
        }
    }

    @MainActor
    private func makeSites() -> [SolcastSettings.Site] {
        [
            SolcastSettings.Site(resourceId: site1ResourceId, apiKey: site1ApiKey, name: site1Name),
            SolcastSettings.Site(resourceId: site2ResourceId, apiKey: site2ApiKey, name: site2Name)
        ].compactMap { $0 }
    }
}
