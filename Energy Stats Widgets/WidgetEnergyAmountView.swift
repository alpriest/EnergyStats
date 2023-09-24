//
//  EnergyAmountView2.swift
//  WidgetExtension
//
//  Created by Alistair Priest on 16/06/2023.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

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
        EnergyText(amount: abs(amount), appTheme: appTheme, type: .batteryCapacity)
            .monospacedDigit()
            .padding(.vertical, 2)
            .padding(.horizontal, 3)
            .cornerRadius(3)
    }
}

struct EnergyAmountView2_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEnergyAmountView(amount: 0.310, decimalPlaces: 3, appTheme: AppTheme.mock())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .containerBackground(for: .widget) {}
    }
}
