//
//  EnergyAmountView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/10/2022.
//

import Combine
import SwiftUI

public struct PowerText: View {
    let amount: Double
    let appSettings: AppSettings
    let type: AmountType

    public init(amount: Double, appSettings: AppSettings, type: AmountType) {
        self.amount = amount
        self.appSettings = appSettings
        self.type = type
    }

    public var body: some View {
        Text(amountWithUnit)
            .accessibilityLabel(type.accessibilityLabel(amount: amount, amountWithUnit: amountWithUnit))
            .monospacedDigit()
    }

    private var amountWithUnit: String {
        switch appSettings.displayUnit {
        case .adaptive:
            if amount < 1 {
                return amount.w()
            } else {
                return amount.kW(appSettings.decimalPlaces)
            }
        case .kilowatt:
            return amount.kW(appSettings.decimalPlaces)
        case .watt:
            return amount.w()
        }
    }
}

public struct EnergyText: View {
    let amount: Double
    let appSettings: AppSettings
    let type: AmountType
    let decimalPlaceOverride: Int?

    public init(amount: Double, appSettings: AppSettings, type: AmountType, decimalPlaceOverride: Int? = nil) {
        self.amount = amount
        self.appSettings = appSettings
        self.type = type
        self.decimalPlaceOverride = decimalPlaceOverride
    }

    public var body: some View {
        Text(amountWithUnit)
            .accessibilityLabel(type.accessibilityLabel(amount: amount, amountWithUnit: amountWithUnit))
            .monospacedDigit()
    }

    private var amountWithUnit: String {
        switch appSettings.displayUnit {
        case .adaptive:
            if amount < 1 {
                return amount.wh()
            } else {
                return amount.kWh(decimalPlaceOverride ?? appSettings.decimalPlaces)
            }
        case .kilowatt:
            return amount.kWh(decimalPlaceOverride ?? appSettings.decimalPlaces)
        case .watt:
            return amount.wh()
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

struct EnergyAmountView_Previews: PreviewProvider {
    static var previews: some View {
//        PowerAmountView(amount: 0.310, backgroundColor: .red, textColor: .black, appSettings: AppSettings.mock(), type: .solarFlow)
        EnergyText(amount: 0.310, appSettings: AppSettings.mock(), type: .solarFlow)
            .background(Color.red)
    }
}
