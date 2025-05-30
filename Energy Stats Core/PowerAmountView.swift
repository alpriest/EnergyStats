//
//  EnergyAmountView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/10/2022.
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
        Text(prefix + amountWithUnit + suffix)
            .accessibilityLabel(type.accessibilityLabel(amount: amount ?? 0, amountWithUnit: amountWithUnit))
            .monospacedDigit()
            .redactedShimmer(when: self.amount == nil)
    }

    private var amountWithUnit: String {
        let amountToUse = amount ?? 0

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

public struct PowerAmountView: View {
    public let amount: Double
    public let backgroundColor: Color
    public let textColor: Color
    public let appSettings: AppSettings
    public let type: AmountType

    public init(amount: Double, backgroundColor: Color, textColor: Color, appSettings: AppSettings, type: AmountType) {
        self.amount = amount
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.appSettings = appSettings
        self.type = type
    }

    public var body: some View {
        Group {
            PowerText(amount: amount, appSettings: appSettings, type: type)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 3)
        .background(backgroundColor)
        .foregroundColor(textColor)
        .cornerRadius(3)
    }
}

#Preview {
    VStack {
        PowerText(amount: nil, appSettings: .mock(), type: .default)
        EnergyText(amount: nil, appSettings: .mock(), type: .default)
    }
}
