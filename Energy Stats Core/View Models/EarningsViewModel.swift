//
//  EarningsViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/09/2023.
//

import Foundation

public struct EarningsViewModel {
    private let response: EarningsResponse
    private let totalsViewModel: TotalsViewModel

    public func today(_ model: FinancialModel) -> Double {
        switch model {
        case .energyStats:
            return 0
        case .foxESS:
            return response.today.earnings
        }
    }

    public func month(_ model: FinancialModel) -> Double {
        switch model {
        case .energyStats:
            return 0
        case .foxESS:
            return response.month.earnings
        }
    }

    public func year(_ model: FinancialModel) -> Double {
        switch model {
        case .energyStats:
            return 0
        case .foxESS:
            return response.year.earnings
        }
    }

    public func cumulate(_ model: FinancialModel) -> Double? {
        switch model {
        case .energyStats:
            return nil
        case .foxESS:
            return response.cumulate.earnings
        }
    }

    public var currencySymbol: String {
        response.currencySymbol
    }

    public init(response: EarningsResponse, totalsViewModel: TotalsViewModel) {
        self.response = response
        self.totalsViewModel = totalsViewModel
    }
}

public extension EarningsViewModel {
    static func any() -> EarningsViewModel {
        EarningsViewModel(response: EarningsResponse(currency: "£",
                                                     today: EarningsResponse.Earning(generation: 1.0, earnings: 1.0),
                                                     month: EarningsResponse.Earning(generation: 2.0, earnings: 2.0),
                                                     year: EarningsResponse.Earning(generation: 3.0, earnings: 3.0),
                                                     cumulate: EarningsResponse.Earning(generation: 1.0, earnings: 1.0)),
                          totalsViewModel: TotalsViewModel(reports: []))
    }

    static func empty() -> EarningsViewModel {
        EarningsViewModel(response: EarningsResponse(currency: "",
                                                     today: EarningsResponse.Earning(generation: 0.0, earnings: 0.0),
                                                     month: EarningsResponse.Earning(generation: 0.0, earnings: 0.0),
                                                     year: EarningsResponse.Earning(generation: 0.0, earnings: 0.0),
                                                     cumulate: EarningsResponse.Earning(generation: 0.0, earnings: 0.0)),
                          totalsViewModel: TotalsViewModel(reports: []))
    }
}
