//
//  EarningsResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 08/05/2023.
//

import Foundation

public struct EarningsResponse: Codable {
    public let currency: String
    public let today: Earning
    public let month: Earning
    public let year: Earning
    public let cumulate: Earning

    public struct Earning: Codable {
        public let generation: Double
        public let earnings: Double
    }

    public var currencySymbol: String {
        if currency.starts(with: "GBP") {
            return "£"
        } else if currency.starts(with: "EUR") {
            return "€"
        } else {
            return currency
        }
    }
}
