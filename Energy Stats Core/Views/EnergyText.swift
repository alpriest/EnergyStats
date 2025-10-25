//
//  EnergyText.swift
//
//
//  Created by Alistair Priest on 09/07/2025.
//

import Combine
import SwiftUI

public struct EnergyText: View {
    let amount: Double?
    let appSettings: AppSettings
    let type: AmountType
    let decimalPlaceOverride: Int?
    let prefix: String
    let suffix: String

    public init(amount: Double?, appSettings: AppSettings, type: AmountType, decimalPlaceOverride: Int? = nil, prefix: String = "", suffix: String = "") {
        self.amount = amount
        self.appSettings = appSettings
        self.type = type
        self.decimalPlaceOverride = decimalPlaceOverride
        self.prefix = prefix
        self.suffix = suffix
    }

    public var body: some View {
        Text(prefix + amount.withUnit(appSettings, decimalPlaceOverride: decimalPlaceOverride) + suffix)
            .accessibilityLabel(
                type.accessibilityLabel(
                    amount: amount ?? 0,
                    amountWithUnit: amount.withUnit(appSettings, decimalPlaceOverride: decimalPlaceOverride)
                )
            )
            .monospacedDigit()
            .redactedShimmer(when: self.amount == nil)
    }
}

public extension Double? {
    func withUnit(_ appSettings: AppSettings, decimalPlaceOverride: Int? = nil) -> String {
        (self ?? 0).withUnit(appSettings, decimalPlaceOverride: decimalPlaceOverride)
    }
}

public extension Double {
    func withUnit(_ appSettings: AppSettings, decimalPlaceOverride: Int? = nil) -> String {
        let amountToUse = self

        switch appSettings.displayUnit {
        case .adaptive:
            if abs(amountToUse) < 1 {
                return amountToUse.wh()
            } else {
                return amountToUse.kWh(decimalPlaceOverride ?? appSettings.decimalPlaces)
            }
        case .kilowatt:
            return amountToUse.kWh(decimalPlaceOverride ?? appSettings.decimalPlaces)
        case .watt:
            return amountToUse.wh()
        }
    }
}
