//
//  EnergyAmountView2.swift
//  WidgetExtension
//
//  Created by Alistair Priest on 16/06/2023.
//

import Energy_Stats_Core
import SwiftUI

public struct WidgetEnergyAmountView: View {
    public let amount: Double
    public let decimalPlaces: Int
    public let appTheme: AppTheme

    public init(amount: Double, decimalPlaces: Int, appTheme: AppTheme) {
        self.amount = amount
        self.decimalPlaces = decimalPlaces
        self.appTheme = appTheme
    }

    public var body: some View {
        HStack {
            EnergyText(amount: amount, appTheme: appTheme)
        }
        .monospacedDigit()
        .padding(3)
        .padding(.horizontal, 4)
        .cornerRadius(3)
    }
}

struct EnergyAmountView2_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEnergyAmountView(amount: 0.310, decimalPlaces: 3, appTheme: AppTheme.mock())
    }
}
