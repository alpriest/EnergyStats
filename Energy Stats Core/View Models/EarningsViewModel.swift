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

public struct EarningsViewModel {
    private let response: EarningsResponse
    private let totalsViewModel: TotalsViewModel
    private let config: FinancialConfigManaging

    public func amounts(_ model: FinancialModel) -> [FinanceAmount] {
        switch model {
        case .energyStats:
            let exportIncome = totalsViewModel.gridExport * config.feedInUnitPrice
            let gridPurchaseCost = totalsViewModel.gridImport * config.gridImportUnitPrice
            let solarSaving = totalsViewModel.solar * config.gridImportUnitPrice
            let total = exportIncome + solarSaving - gridPurchaseCost

            return [
                FinanceAmount(title: .exportedIncome, amount: exportIncome, currencySymbol: response.currencySymbol),
                FinanceAmount(title: .importedCost, amount: gridPurchaseCost, currencySymbol: response.currencySymbol),
                FinanceAmount(title: .solarSavings, amount: solarSaving, currencySymbol: response.currencySymbol),
                FinanceAmount(title: .total, amount: total, currencySymbol: response.currencySymbol)
            ]
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

    public init(response: EarningsResponse, totalsViewModel: TotalsViewModel, config: FinancialConfigManaging) {
        self.response = response
        self.totalsViewModel = totalsViewModel
        self.config = config
    }
}

public extension EarningsViewModel {
    static func any() -> EarningsViewModel {
        EarningsViewModel(response: EarningsResponse(currency: "£",
                                                     today: EarningsResponse.Earning(generation: 1.0, earnings: 1.0),
                                                     month: EarningsResponse.Earning(generation: 2.0, earnings: 2.0),
                                                     year: EarningsResponse.Earning(generation: 3.0, earnings: 3.0),
                                                     cumulate: EarningsResponse.Earning(generation: 1.0, earnings: 1.0)),
                          totalsViewModel: TotalsViewModel(reports: []),
                          config: PreviewConfigManager())
    }

    static func empty() -> EarningsViewModel {
        EarningsViewModel(response: EarningsResponse(currency: "",
                                                     today: EarningsResponse.Earning(generation: 0.0, earnings: 0.0),
                                                     month: EarningsResponse.Earning(generation: 0.0, earnings: 0.0),
                                                     year: EarningsResponse.Earning(generation: 0.0, earnings: 0.0),
                                                     cumulate: EarningsResponse.Earning(generation: 0.0, earnings: 0.0)),
                          totalsViewModel: TotalsViewModel(reports: []),
                          config: PreviewConfigManager())
    }
}
