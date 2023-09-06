//
//  EarningsViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/09/2023.
//

import Foundation

public struct EarningsViewModel {
    public let today: Double
    public let month: Double
    public let year: Double
    public let cumulate: Double
    public let currencySymbol: String

    public init(today: Double, month: Double, year: Double, cumulate: Double, currencySymbol: String) {
        self.today = today
        self.month = month
        self.year = year
        self.cumulate = cumulate
        self.currencySymbol = currencySymbol
    }
}

public extension EarningsViewModel {
    static func any() -> EarningsViewModel {
        EarningsViewModel(today: 1.0, month: 5.0, year: 89.1, cumulate: 121.1, currencySymbol: "£")
    }

    static func empty() -> EarningsViewModel {
        EarningsViewModel(today: 0.0, month: 0.0, year: 0.0, cumulate: 0.0, currencySymbol: "")
    }
}
