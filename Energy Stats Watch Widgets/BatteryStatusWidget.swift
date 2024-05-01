//
//  BatteryStatusWidget.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 28/04/2024.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct BatteryStatusWidget: Widget {
    let kind: String = "BatteryCornerWidget"
    @Environment(\.widgetFamily) var family
    let circularGradient = Gradient(colors: [.red, .orange, .yellow, .green])

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(deviceSN: KeychainStore().getSelectedDeviceSN())) { entry in
            Group {
                if let soc = entry.soc {
                    switch family {
                    case .accessoryCircular:
                        Gauge(value: Double(soc), in: 0 ... 100) {
                            Image(systemName: "minus.plus.batteryblock.fill")
                                .font(.system(size: 14))
                        } currentValueLabel: {
                            Text(soc, format: .percent)
                        }.gaugeStyle(CircularGaugeStyle(tint: circularGradient))
                    default:
                        Text(soc, format: .percent)
                            .widgetLabel("SoC")
                    }
                } else {
                    if let errorMessage = entry.errorMessage {
                        Text("")
                            .widgetLabel(errorMessage)
                    } else {
                        Text("??")
                    }
                }
            }
            .widgetCurvesContent()
            .containerBackground(for: .widget) {
                Color.clear
            }
        }
        .configurationDisplayName("Battery Status")
        .description("Shows the status of your home battery")
        .supportedFamilies([.accessoryInline,
                            .accessoryCorner,
                            .accessoryCircular,
                            .accessoryRectangular])
    }
}

#Preview(as: .accessoryCircular) {
    BatteryStatusWidget()
} timeline: {
    SimpleEntry(date: .now, soc: 25, chargeStatusDescription: "S", state: .loaded, errorMessage: nil)
}
