//
//  ApproximationsSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 01/10/2023.
//

import SwiftUI
import Energy_Stats_Core

class ApproximationsSettingsViewModel: ObservableObject {
    @Published var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode {
        didSet {
            configManager.selfSufficiencyEstimateMode = selfSufficiencyEstimateMode
        }
    }

    @Published var showFinancialSummary: Bool {
        didSet {
            configManager.showFinancialEarnings = showFinancialSummary
        }
    }

    @Published var showFinancialSavings: Bool {
        didSet {
            configManager.showFinancialSavings = showFinancialSavings
        }
    }

    @Published var showFinancialCosts: Bool {
        didSet {
            configManager.showFinancialCosts = showFinancialCosts
        }
    }

    @Published var financialModel: FinancialModel {
        didSet {
            configManager.financialModel = financialModel
        }
    }

    @Published var foxFeedInUnitPrice = "0.30" // TODO: Read from Fox (https://www.foxesscloud.com/sapn/v0/plant/get?stationID=760f8106-a59b-45ee-bf81-1665e9e9429d)
    @Published var energyStatsFeedInUnitPrice: String {
        didSet {
            configManager.feedInUnitPrice = Double(energyStatsFeedInUnitPrice) ?? 0.0
        }
    }

    @Published var energyStatsGridImportUnitPrice: String {
        didSet {
            configManager.gridImportUnitPrice = Double(energyStatsGridImportUnitPrice) ?? 0.0
        }
    }

    private(set) var configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        selfSufficiencyEstimateMode = configManager.selfSufficiencyEstimateMode
        showFinancialSummary = configManager.showFinancialEarnings
        showFinancialSavings = configManager.showFinancialSavings
        showFinancialCosts = configManager.showFinancialCosts
        financialModel = configManager.financialModel
        energyStatsFeedInUnitPrice = String(configManager.feedInUnitPrice)
        energyStatsGridImportUnitPrice = String(configManager.gridImportUnitPrice)
    }
}
