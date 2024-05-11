//
//  EarningsViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/09/2023.
//

import Foundation

public struct FinanceAmount: Hashable, Identifiable {
    public let title: LocalizedString.Key
    public let amount: Double

    public init(title: LocalizedString.Key, amount: Double) {
        self.title = title
        self.amount = amount
    }

    public func formattedAmount(_ currencySymbol: String) -> String {
        amount.roundedToString(decimalPlaces: 2, currencySymbol: currencySymbol)
    }

    public var id: String { title.rawValue }
}

public struct EnergyStatsFinancialModel {
    private let config: FinancialConfigManaging
    public let exportIncome: FinanceAmount
    public let solarSaving: FinanceAmount
    public let total: FinanceAmount
    public let exportBreakdown: CalculationBreakdown
    public let solarSavingBreakdown: CalculationBreakdown

    public init(totalsViewModel: TotalsViewModel, config: FinancialConfigManaging) {
        self.config = config

        exportIncome = FinanceAmount(title: .exportedIncomeShortTitle, amount: totalsViewModel.gridExport * config.feedInUnitPrice)
        exportBreakdown = CalculationBreakdown(
            formula: "gridExport * feedInUnitPrice",
            calculation: { dp in "\(totalsViewModel.gridExport.roundedToString(decimalPlaces: dp)) * \(config.feedInUnitPrice.roundedToString(decimalPlaces: dp))" }
        )

        solarSaving = FinanceAmount(title: .gridImportAvoidedShortTitle, amount: (totalsViewModel.solar - totalsViewModel.gridExport) * config.gridImportUnitPrice)
        solarSavingBreakdown = CalculationBreakdown(
            formula: "(solar - gridExport) * gridImportUnitPrice",
            calculation: { dp in "(\(totalsViewModel.solar.roundedToString(decimalPlaces: dp)) - \(totalsViewModel.gridExport.roundedToString(decimalPlaces: dp))) * \(config.gridImportUnitPrice.roundedToString(decimalPlaces: dp))" }
        )

        total = FinanceAmount(title: .total, amount: exportIncome.amount + solarSaving.amount)
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
