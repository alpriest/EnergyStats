//
//  FinanceAmount.swift
//  Energy Stats
//
//  Created by Alistair Priest on 12/01/2026.
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
