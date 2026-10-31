//
//  FinancialsSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/10/2023.
//

import Energy_Stats_Core
import Foundation
import Combine

@Observable
class FinancialsSettingsViewModel {
    private var cancellables = Set<AnyCancellable>()

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

    var feedInPriceRates: [EnergyPriceRate]
    var gridImportPriceRates: [EnergyPriceRate]

    private(set) var configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        showFinancialSummary = configManager.showFinancialEarnings
        showFinancialSummaryOnFlowPage = configManager.showFinancialSummaryOnFlowPage
        earningsModel = configManager.earningsModel
        installationPurchasePrice = configManager.installationPurchasePrice.roundedToString(decimalPlaces: 0)
        deductInverterConsumptionFromGridAvoided = configManager.deductInverterConsumptionFromGridAvoided
        feedInPriceRates = configManager.feedInPriceRates
        gridImportPriceRates = configManager.gridImportPriceRates

        configManager.appSettingsPublisher.sink { [weak self] theme in
            guard let self else { return }
            Task { @MainActor in
                self.feedInPriceRates = configManager.feedInPriceRates
                self.gridImportPriceRates = configManager.gridImportPriceRates
            }
        }.store(in: &cancellables)
    }
}
