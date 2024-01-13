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
    private let currencySymbol: String

    public init(title: LocalizedString.Key, amount: Double, currencySymbol: String) {
        self.title = title
        self.amount = amount
        self.currencySymbol = currencySymbol
    }

    public func formattedAmount() -> String {
        amount.roundedToString(decimalPlaces: 2, currencySymbol: currencySymbol)
    }

    public var id: String { title.rawValue }
}

public struct EnergyStatsFinancialModel {
    private let config: FinancialConfigManaging
    let currencySymbol: String
    public let exportIncome: FinanceAmount
    public let solarSaving: FinanceAmount
    public let total: FinanceAmount
    public let exportBreakdown: CalculationBreakdown
    public let solarSavingBreakdown: CalculationBreakdown

    public init(totalsViewModel: TotalsViewModel, config: FinancialConfigManaging, currencySymbol: String) {
        self.config = config
        self.currencySymbol = currencySymbol

        exportIncome = FinanceAmount(title: .exportedIncomeShortTitle, amount: totalsViewModel.gridExport * config.feedInUnitPrice, currencySymbol: currencySymbol)
        exportBreakdown = CalculationBreakdown(
            formula: "gridExport * feedInUnitPrice",
            calculation: { dp in "\(totalsViewModel.gridExport.roundedToString(decimalPlaces: dp)) * \(config.feedInUnitPrice.roundedToString(decimalPlaces: dp))" }
        )

        solarSaving = FinanceAmount(title: .gridImportAvoidedShortTitle, amount: (totalsViewModel.solar - totalsViewModel.gridExport) * config.gridImportUnitPrice, currencySymbol: currencySymbol)
        solarSavingBreakdown = CalculationBreakdown(
            formula: "(solar - gridExport) * gridImportUnitPrice",
            calculation: { dp in "(\(totalsViewModel.solar.roundedToString(decimalPlaces: dp)) - \(totalsViewModel.gridExport.roundedToString(decimalPlaces: dp))) * \(config.gridImportUnitPrice.roundedToString(decimalPlaces: dp))" }
        )

        total = FinanceAmount(title: .total, amount: exportIncome.amount + solarSaving.amount, currencySymbol: currencySymbol)
    }

    func amounts() -> [FinanceAmount] {
        [exportIncome, solarSaving, total]
    }
}

public struct EarningsViewModel {
    private let energyStatsFinancialModel: EnergyStatsFinancialModel

    public func amounts(_ model: FinancialModel) -> [FinanceAmount] {
        switch model {
        case .energyStats:
            return energyStatsFinancialModel.amounts()
        case .foxESS:
            return []
        }
    }

    public var currencySymbol: String {
        energyStatsFinancialModel.currencySymbol
    }

    public init(energyStatsFinancialModel: EnergyStatsFinancialModel) {
        self.energyStatsFinancialModel = energyStatsFinancialModel
    }
}

public extension EarningsViewModel {
    static func any() -> EarningsViewModel {
        EarningsViewModel(energyStatsFinancialModel: EnergyStatsFinancialModel(totalsViewModel: TotalsViewModel(reports: []),
                                                                               config: PreviewConfigManager(),
                                                                               currencySymbol: "£"))
    }

    static func empty() -> EarningsViewModel {
        EarningsViewModel(energyStatsFinancialModel: EnergyStatsFinancialModel(totalsViewModel: TotalsViewModel(reports: []),
                                                                               config: PreviewConfigManager(),
                                                                               currencySymbol: "£"))
    }
}
