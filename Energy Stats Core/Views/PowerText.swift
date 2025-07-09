//
//  PowerText.swift
//
//
//  Created by Alistair Priest on 09/07/2025.
//

import Combine
import SwiftUI

public struct PowerText: View {
    let amount: Double?
    let appSettings: AppSettings
    let type: AmountType
    let decimalPlaceOverride: Int?

    public init(amount: Double?, appSettings: AppSettings, type: AmountType, decimalPlaceOverride: Int? = nil) {
        self.amount = amount
        self.appSettings = appSettings
        self.type = type
        self.decimalPlaceOverride = decimalPlaceOverride
    }

    public var body: some View {
        Text(amountWithUnit)
            .accessibilityLabel(type.accessibilityLabel(amount: amount ?? 0, amountWithUnit: amountWithUnit))
            .monospacedDigit()
            .redactedShimmer(when: self.amount == nil)
    }

    private var amountWithUnit: String {
        let amountToUse = amount ?? 0

        switch appSettings.displayUnit {
        case .adaptive:
            if abs(amountToUse) < 1 {
                return amountToUse.w()
            } else {
                return amountToUse.kW(decimalPlaceOverride ?? appSettings.decimalPlaces)
            }
        case .kilowatt:
            return amountToUse.kW(decimalPlaceOverride ?? appSettings.decimalPlaces)
        case .watt:
            return amountToUse.w()
        }
    }
}
