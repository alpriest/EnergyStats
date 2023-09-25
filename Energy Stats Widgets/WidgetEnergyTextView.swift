//
//  EnergyAmountView2.swift
//  WidgetExtension
//
//  Created by Alistair Priest on 16/06/2023.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct WidgetEnergyTextView: View {
    let amount: Double
    let decimalPlaces: Int
    let appTheme: AppTheme

    init(amount: Double, decimalPlaces: Int, appTheme: AppTheme) {
        self.amount = amount
        self.decimalPlaces = decimalPlaces
        self.appTheme = appTheme
    }

    var body: some View {
        EnergyText(amount: abs(amount), appTheme: appTheme, type: .batteryCapacity)
            .monospacedDigit()
            .padding(.vertical, 2)
            .padding(.horizontal, 3)
            .cornerRadius(3)
    }
}

#if DEBUG
#Preview {
    WidgetEnergyTextView(amount: 0.310, decimalPlaces: 3, appTheme: AppTheme.mock())
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .containerBackground(for: .widget) {}
}
#endif
