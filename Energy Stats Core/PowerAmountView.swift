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
    let appTheme: AppTheme

    public init(amount: Double, appTheme: AppTheme) {
        self.amount = amount
        self.appTheme = appTheme
    }

    public var body: some View {
        if appTheme.showInW {
            Text(amount.w())
        } else {
            Text(amount.kW(appTheme.decimalPlaces))
        }
    }
}

public struct EnergyText: View {
    let amount: Double
    let appTheme: AppTheme

    public init(amount: Double, appTheme: AppTheme) {
        self.amount = amount
        self.appTheme = appTheme
    }

    public var body: some View {
        if appTheme.showInW {
            Text(amount.wh())
        } else {
            Text(amount.kWh(appTheme.decimalPlaces))
        }
    }
}

public struct PowerAmountView: View {
    public let amount: Double
    public let backgroundColor: Color
    public let textColor: Color
    public let appTheme: AppTheme

    public init(amount: Double, backgroundColor: Color, textColor: Color, appTheme: AppTheme) {
        self.amount = amount
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.appTheme = appTheme
    }

    public var body: some View {
        Group {
            PowerText(amount: amount, appTheme: appTheme)
        }
        .padding(3)
        .padding(.horizontal, 4)
        .background(backgroundColor)
        .foregroundColor(textColor)
        .cornerRadius(3)
    }
}

struct EnergyAmountView_Previews: PreviewProvider {
    static var previews: some View {
        PowerAmountView(amount: 0.310, backgroundColor: .red, textColor: .black, appTheme: AppTheme.mock())
    }
}

public extension AppTheme {
    static func mock(decimalPlaces: Int = 3, showInW: Bool = false, showInverterTemperature: Bool = false) -> AppTheme {
        AppTheme(
            showColouredLines: true,
            showBatteryTemperature: true,
            showSunnyBackground: true,
            decimalPlaces: decimalPlaces,
            showBatteryEstimate: true,
            showUsableBatteryOnly: false,
            showInW: showInW,
            showTotalYield: false,
            selfSufficiencyEstimateMode: .off,
            showEarnings: false,
            showInverterTemperature: showInverterTemperature
        )
    }
}
