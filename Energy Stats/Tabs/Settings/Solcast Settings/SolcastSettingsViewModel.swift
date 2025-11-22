//
//  SolcastSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/11/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

struct SolcastSettingsViewData: Copiable, Equatable {
    var sites: [SolcastSite]
    var apiKey: String

    func create(copying previous: SolcastSettingsViewData) -> SolcastSettingsViewData {
        SolcastSettingsViewData(
            sites: previous.sites,
            apiKey: previous.apiKey
        )
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        let lhsNames = lhs.sites.map { $0.name }
        let rhsNames = rhs.sites.map { $0.name }
        return lhs.apiKey == rhs.apiKey && lhsNames == rhsNames
    }
}

class SolcastSettingsViewModel: ObservableObject, ViewDataProviding {
    typealias ViewData = SolcastSettingsViewData
    
    private var configManager: ConfigManaging
    @Published var alertContent: AlertContent?
    private let solarService: SolarForecastProviding
    @Published var fetchSolcastOnAppLaunch: Bool = false {
        didSet {
            configManager.fetchSolcastOnAppLaunch = fetchSolcastOnAppLaunch
        }
    }

    @Published var viewData: ViewData = .init(sites: [], apiKey: "") { didSet {
        isDirty = viewData != originalValue
    }}
    @Published var isDirty = false
    var originalValue: ViewData? = nil

    init(configManager: ConfigManaging, solarService: @escaping SolarForecastProviding) {
        self.configManager = configManager
        self.solarService = solarService

        let viewData = ViewData(sites: configManager.solcastSettings.sites,
                                               apiKey: configManager.solcastSettings.apiKey ?? "")
        self.originalValue = viewData

        Task { @MainActor in
            self.viewData = viewData
            fetchSolcastOnAppLaunch = configManager.fetchSolcastOnAppLaunch
        }
    }

    @MainActor
    func save() {
        Task { @MainActor in
            do {
                let service = solarService()
                let response = try await service.fetchSites(apiKey: viewData.apiKey)
                configManager.solcastSettings = SolcastSettings(apiKey: viewData.apiKey, sites: response.sites.map { SolcastSite(site: $0) })
                self.viewData = viewData.copy {
                    $0.sites = configManager.solcastSettings.sites
                }
                resetDirtyState()

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
            viewData = viewData.copy {
                $0.apiKey = ""
                $0.sites = []
            }
        }
    }
}
