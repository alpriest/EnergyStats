//
//  EarningsViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/09/2023.
//

import Foundation

public struct FinanceAmount: Hashable, Identifiable {
    public let title: LocalizedString.Key
    let amount: Double
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
    private let totalsViewModel: TotalsViewModel
    private let config: FinancialConfigManaging
    private let currencySymbol: String
    public let exportIncome: FinanceAmount
    public let solarSaving: FinanceAmount
    public let total: FinanceAmount

    public init(totalsViewModel: TotalsViewModel, config: FinancialConfigManaging, currencySymbol: String) {
        self.totalsViewModel = totalsViewModel
        self.config = config
        self.currencySymbol = currencySymbol

        exportIncome = FinanceAmount(title: .exportedIncome, amount: totalsViewModel.gridExport * config.feedInUnitPrice, currencySymbol: currencySymbol)
        solarSaving = FinanceAmount(title: .gridImportAvoidedShortTitle, amount: totalsViewModel.solar * config.gridImportUnitPrice, currencySymbol: currencySymbol)
        total = FinanceAmount(title: .total, amount: exportIncome.amount + solarSaving.amount, currencySymbol: currencySymbol)
    }

    func amounts() -> [FinanceAmount] {
        [exportIncome, solarSaving, total]
    }
}

public struct EarningsViewModel {
    private let response: EarningsResponse
    private let energyStatsFinancialModel: EnergyStatsFinancialModel

    public func amounts(_ model: FinancialModel) -> [FinanceAmount] {
        switch model {
        case .energyStats:
            return energyStatsFinancialModel.amounts()
        case .foxESS:
            return [
                FinanceAmount(title: .today, amount: response.today.earnings, currencySymbol: response.currencySymbol),
                FinanceAmount(title: .month, amount: response.month.earnings, currencySymbol: response.currencySymbol),
                FinanceAmount(title: .year, amount: response.year.earnings, currencySymbol: response.currencySymbol),
                FinanceAmount(title: .total, amount: response.cumulate.earnings, currencySymbol: response.currencySymbol)
            ]
        }
    }

    public var currencySymbol: String {
        response.currencySymbol
    }

    public init(response: EarningsResponse, energyStatsFinancialModel: EnergyStatsFinancialModel) {
        self.response = response
        self.energyStatsFinancialModel = energyStatsFinancialModel
    }
}

public extension EarningsViewModel {
    static func any() -> EarningsViewModel {
        EarningsViewModel(response: EarningsResponse(currency: "£",
                                                     today: EarningsResponse.Earning(generation: 1.0, earnings: 1.0),
                                                     month: EarningsResponse.Earning(generation: 2.0, earnings: 2.0),
                                                     year: EarningsResponse.Earning(generation: 3.0, earnings: 3.0),
                                                     cumulate: EarningsResponse.Earning(generation: 1.0, earnings: 1.0)),
                          energyStatsFinancialModel: EnergyStatsFinancialModel(totalsViewModel: TotalsViewModel(reports: []),
                                                                               config: PreviewConfigManager(),
                                                                               currencySymbol: "£"))
    }

    static func empty() -> EarningsViewModel {
        EarningsViewModel(response: EarningsResponse(currency: "£",
                                                     today: EarningsResponse.Earning(generation: 0.0, earnings: 0.0),
                                                     month: EarningsResponse.Earning(generation: 0.0, earnings: 0.0),
                                                     year: EarningsResponse.Earning(generation: 0.0, earnings: 0.0),
                                                     cumulate: EarningsResponse.Earning(generation: 0.0, earnings: 0.0)),
                          energyStatsFinancialModel: EnergyStatsFinancialModel(totalsViewModel: TotalsViewModel(reports: []),
                                                                               config: PreviewConfigManager(),
                                                                               currencySymbol: "£"))
    }
}
