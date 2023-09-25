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
    @Environment(\.widgetFamily) var family
    let soc: Double
    let chargeStatusDescription: String?
    let lastUpdated: Date
    let appTheme: AppTheme

    var body: some View {
        switch self.family {
        case .systemSmall:
            VStack {
                gaugeView()
                descriptionView()
                Text(lastUpdated, format: .dateTime)
                    .font(.system(size: 8.0, weight: .light))
            }
        default:
            VStack(spacing: 24) {
                HStack(spacing: 44) {
                    gaugeView()
                    descriptionView()
                        .font(.title)
                }
                Text(lastUpdated, format: .dateTime)
                    .font(.system(size: 12.0, weight: .light))
            }
        }
    }

    private func gaugeView() -> some View {
        Button(intent: UpdateBatteryChargeLevelIntent()) {
            Gauge(value: soc) {
                Image(systemName: "minus.plus.batteryblock.fill")
                    .font(.system(size: 16))
            } currentValueLabel: {
                Text(soc, format: .percent)
            }
            .gaugeStyle(.accessoryCircular)
            .scaleEffect(1.2)
            .padding(.bottom, 4)
            .tint(tint)
        }.buttonStyle(.plain)
    }

    private func descriptionView() -> some View {
        OptionalView(chargeStatusDescription) {
            Text($0)
                .multilineTextAlignment(.center)
        }
    }

    private var tint: Color {
        if soc < 0.40 {
            return .red
        } else if soc < 0.70 {
            return .orange
        } else {
            return .green
        }
    }
}

struct BatteryStatusView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryStatusView(
            soc: 0.8,
            chargeStatusDescription: "Empty in 15 hours",
            lastUpdated: .now,
            appTheme: .mock()
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .containerBackground(for: .widget) {}

        BatteryStatusView(
            soc: 0.8,
            chargeStatusDescription: "Empty in 15 hours",
            lastUpdated: .now,
            appTheme: .mock()
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .containerBackground(for: .widget) {}
    }
}
