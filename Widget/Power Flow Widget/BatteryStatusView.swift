//
//  BatteryStatusView.swift
//  WidgetExtension
//
//  Created by Alistair Priest on 15/06/2023.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct BatteryStatusView: View {
    let soc: Double
    let battery: Double
    let appTheme: AppTheme

    var body: some View {
        VStack {
            Gauge(value: soc) {
                Image(systemName: "minus.plus.batteryblock.fill")
                    .font(.system(size: 16))
            } currentValueLabel: {
                Text(soc, format: .percent)
            }
            .gaugeStyle(.accessoryCircular)
            .scaleEffect(1.2)
            .padding(.bottom, 4)

            HStack(spacing: 0) {
                FlowArrow(
                    amount: battery,
                    color: appTheme.lineColor(for: battery, showColour: true)
                )

                WidgetEnergyAmountView(
                    amount: battery,
                    decimalPlaces: appTheme.decimalPlaces,
                    appTheme: appTheme
                )
                .font(.system(size: 18))
            }
        }
    }
}

struct BatteryStatusView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryStatusView(
            soc: 70,
            battery: 0.98,
            appTheme: .mock()
        ).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
