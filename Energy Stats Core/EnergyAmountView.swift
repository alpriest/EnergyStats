//
//  EnergyAmountView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/10/2022.
//

import Combine
import SwiftUI

public struct EnergyAmountView: View {
    public let amount: Double
    public let decimalPlaces: Int
    public let backgroundColor: Color
    public let textColor: Color
    public let appTheme: AppTheme

    public init(amount: Double, decimalPlaces: Int, backgroundColor: Color, textColor: Color, appTheme: AppTheme) {
        self.amount = amount
        self.decimalPlaces = decimalPlaces
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.appTheme = appTheme
    }

    public var body: some View {
        Color.clear.overlay(
            Group {
                if appTheme.showInW {
                    Text(amount.w())
                } else {
                    Text(amount.kW(decimalPlaces))
                }
            }
            .padding(3)
            .padding(.horizontal, 4)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(3)
        )
    }
}

struct EnergyAmountView_Previews: PreviewProvider {
    static var previews: some View {
        EnergyAmountView(amount: 0.310, decimalPlaces: 3, backgroundColor: .red, textColor: .black, appTheme: AppTheme.mock())
    }
}

public extension AppTheme {
    static func mock() -> AppTheme {
        AppTheme(
            showColouredLines: true,
            showBatteryTemperature: true,
            showSunnyBackground: true,
            decimalPlaces: 3,
            showBatteryEstimate: true,
            showUsableBatteryOnly: false,
            showInW: false,
            showTotalYield: false
        )
    }
}
