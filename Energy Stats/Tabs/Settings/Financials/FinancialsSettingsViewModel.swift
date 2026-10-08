//
//  FinancialsSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/10/2023.
//

import Energy_Stats_Core
import Foundation

@Observable
class FinancialsSettingsViewModel {
    var earningsModel: EarningsModel {
        didSet {
            configManager.earningsModel = earningsModel
        }
    }

    var showFinancialSummary: Bool {
        didSet {
            configManager.showFinancialEarnings = showFinancialSummary

            if !showFinancialSummary {
                showFinancialSummaryOnFlowPage = false
            }
        }
    }

    var showFinancialSummaryOnFlowPage: Bool {
        didSet {
            configManager.showFinancialSummaryOnFlowPage = showFinancialSummaryOnFlowPage
        }
    }

    var energyStatsFeedInUnitPrice: String {
        didSet {
            configManager.feedInUnitPrice = energyStatsFeedInUnitPrice.asCurrencyStringToDouble()
        }
    }

    var energyStatsGridImportUnitPrice: String {
        didSet {
            configManager.gridImportUnitPrice = energyStatsGridImportUnitPrice.asCurrencyStringToDouble()
        }
    }
    
    var installationPurchasePrice: String {
        didSet {
            configManager.installationPurchasePrice = installationPurchasePrice.asCurrencyStringToDouble()
        }
    }
    
    var deductInverterConsumptionFromGridAvoided: Bool {
        didSet {
            configManager.deductInverterConsumptionFromGridAvoided = deductInverterConsumptionFromGridAvoided
        }
    }

    private(set) var configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        showFinancialSummary = configManager.showFinancialEarnings
        showFinancialSummaryOnFlowPage = configManager.showFinancialSummaryOnFlowPage
        energyStatsFeedInUnitPrice = configManager.feedInUnitPrice.roundedToString(decimalPlaces: 3)
        energyStatsGridImportUnitPrice = configManager.gridImportUnitPrice.roundedToString(decimalPlaces: 3)
        earningsModel = configManager.earningsModel
        installationPurchasePrice = configManager.installationPurchasePrice.roundedToString(decimalPlaces: 0)
        deductInverterConsumptionFromGridAvoided = configManager.deductInverterConsumptionFromGridAvoided
    }
}
