//
//  EarningsViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/09/2023.
//

import Foundation

public struct FinanceAmount: Hashable, Identifiable {
    public let shortTitle: LocalizedString.Key
    public let longTitle: LocalizedString.Key
    public let accessibilityKey: LocalizedString.Key.Accessibility
    public let amount: Double

    public init(shortTitle: LocalizedString.Key, longTitle: LocalizedString.Key, accessibilityKey: LocalizedString.Key.Accessibility, amount: Double) {
        self.shortTitle = shortTitle
        self.longTitle = longTitle
        self.accessibilityKey = accessibilityKey
        self.amount = amount
    }

    public init(title: LocalizedString.Key, accessibilityKey: LocalizedString.Key.Accessibility, amount: Double) {
        self.init(shortTitle: title, longTitle: title, accessibilityKey: accessibilityKey, amount: amount)
    }

    public func formattedAmount(_ currencySymbol: String) -> String {
        amount.roundedToString(decimalPlaces: 2, currencySymbol: currencySymbol)
    }

    public func accessibilityLabel(_ currencySymbol: String) -> String {
        String(format: String(accessibilityKey: accessibilityKey), arguments: [formattedAmount(currencySymbol)])
    }

    public var id: String { shortTitle.rawValue }
}

public struct EnergyStatsFinancialModel {
    private let config: FinancialConfigManager
    public let exportIncome: FinanceAmount
    public let solarSaving: FinanceAmount
    public let total: FinanceAmount
    public let exportBreakdown: CalculationBreakdown
    public let solarSavingBreakdown: CalculationBreakdown

    public init(totalsViewModel: TotalsViewModel, config: FinancialConfigManager) {
        self.config = config

        let amountForIncomeCalculation = config.earningsModel == .exported ? totalsViewModel.gridExport : totalsViewModel.solar
        
        exportIncome = FinanceAmount(
            shortTitle: config.earningsModel == .exported ? .exportedIncomeShortTitle : .generatedIncomeShortTitle,
            longTitle: config.earningsModel == .exported ? .exportedIncomeLongTitle : .generationIncomeLongTitle,
            accessibilityKey: config.earningsModel == .exported ? .totalExportIncomeToday : .totalGeneratedIncomeToday,
            amount: amountForIncomeCalculation * config.feedInUnitPrice
        )
        exportBreakdown = CalculationBreakdown(
            formula: "\(String(key: config.earningsModel == .exported ? .exportedIncomeShortTitle : .generatedIncomeShortTitle)) * feedInUnitPrice",
            calculation: { dp in "\(amountForIncomeCalculation.roundedToString(decimalPlaces: dp)) * \(config.feedInUnitPrice.roundedToString(decimalPlaces: dp))" }
        )

        solarSaving = FinanceAmount(
            title: .gridImportAvoidedShortTitle,
            accessibilityKey: .totalAvoidedCostsToday,
            amount: max(0, (totalsViewModel.solar - totalsViewModel.gridExport)) * config.gridImportUnitPrice
        )
        solarSavingBreakdown = CalculationBreakdown(
            formula: "max(0, solar - gridExport) * gridImportUnitPrice",
            calculation: { dp in "max (0, \(totalsViewModel.solar.roundedToString(decimalPlaces: dp)) - \(totalsViewModel.gridExport.roundedToString(decimalPlaces: dp))) * \(config.gridImportUnitPrice.roundedToString(decimalPlaces: dp))" }
        )

        total = FinanceAmount(
            title: .total,
            accessibilityKey: .totalIncomeToday,
            amount: exportIncome.amount + solarSaving.amount
        )
    }

    public func amounts() -> [FinanceAmount] {
        [exportIncome, solarSaving, total]
    }
}

public extension EnergyStatsFinancialModel {
    static func any() -> EnergyStatsFinancialModel {
        EnergyStatsFinancialModel(totalsViewModel: TotalsViewModel(reports: []),
                                  config: ConfigManager.preview())
    }

    static func empty() -> EnergyStatsFinancialModel { any() }
}
