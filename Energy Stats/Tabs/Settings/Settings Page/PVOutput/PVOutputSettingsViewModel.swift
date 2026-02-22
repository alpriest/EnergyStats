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
    private let foxService: Networking

    @Published var viewData: ViewData = .initial { didSet {
        isDirty = viewData != originalValue
    }}
    @Published var isDirty = false
    var originalValue: ViewData? = nil
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?

    init(configManager: ConfigManaging, foxService: Networking, pvOutputService: PVOutputServicing) {
        self.configManager = configManager
        self.foxService = foxService
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

    func upload() async {
        guard let deviceSN = configManager.selectedDeviceSN else { return }

        do {
            let queryDate = QueryDate(from: viewData.startDate)
            let reports = try await foxService.fetchReport(
                deviceSN: deviceSN,
                variables: [.pvEnergyTotal, .feedIn],
                queryDate: queryDate,
                reportType: .month
            )
            let pvEnergyTotal = reports.dateValue(for: .pvEnergyTotal, date: viewData.startDate)
            let feedIn = reports.dateValue(for: .feedIn, date: viewData.startDate)
            
            try await pvOutputService.post(output: PVOutputRecord(outputDate: viewData.startDate, generated: pvEnergyTotal * 1000.0, exported: feedIn * 1000.0))
            alertContent = AlertContent(title: "Success", message: "Data exported")
        } catch {}
    }
}

extension Array where Element == OpenReportResponse {
    
}
