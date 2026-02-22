//
//  PVOutputSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/02/2026.
//

import Energy_Stats_Core
import SwiftUI

class PVOutputSettingsViewModel: ObservableObject, HasLoadState, ViewDataProviding {
    typealias ViewData = PVOutputSettingsViewData

    private var configManager: ConfigManaging
    private let pvOutputService: PVOutputServicing

    @Published var viewData: ViewData = .initial { didSet {
        isDirty = viewData != originalValue
    }}
    @Published var isDirty = false
    var originalValue: ViewData? = nil
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?

    init(configManager: ConfigManaging, pvOutputService: PVOutputServicing) {
        self.configManager = configManager
        self.pvOutputService = pvOutputService
        let config = configManager.pvOutputConfig
        let viewData = ViewData(apiKey: config?.apiKey ?? "",
                                systemId: config?.systemId ?? "",
                                startDate: .yesterday(),
                                endDate: .yesterday(),
                                validCredentials: config != nil)
        self.originalValue = viewData

        Task { @MainActor in
            self.viewData = viewData
        }
    }

    @MainActor
    func verifyCredentials() async {
        await setState(.active(.saving))

        let config = PVOutputConfig(apiKey: viewData.apiKey, systemId: viewData.systemId)
        let valid = await pvOutputService.verify(credentials: config)
        Task { @MainActor in
            viewData = viewData.copy {
                $0.validCredentials = valid
            }

            if valid {
                configManager.pvOutputConfig = config
            } else {
                alertContent = AlertContent(title: "Failed", message: "pvoutput_settings_invalid")
            }
        }

        await setState(.inactive)
    }

    func clearCredentials() {
        Task { @MainActor in
            configManager.pvOutputConfig = nil
            viewData = viewData.copy {
                $0.apiKey = ""
                $0.systemId = ""
                $0.validCredentials = false
            }
        }
    }

    func removeKey() {
        configManager.pvOutputConfig = nil
    }
}
