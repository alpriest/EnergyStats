//
//  BatteryStatusWidget.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 28/04/2024.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct BatteryGaugeView: View {
    let circularGradient = Gradient(colors: [.red, .orange, .yellow, .green])
    let value: Int
    let batteryPower: Double?

    var body: some View {
        Gauge(value: Double(value), in: 0 ... 100) {
            Image(systemName: "minus.plus.batteryblock.fill")
                .font(.system(size: 14))
                .foregroundStyle(batteryPower.tintColor)
        } currentValueLabel: {
            Text(value, format: .percent)
        }.gaugeStyle(CircularGaugeStyle(tint: circularGradient))
    }
}

struct CircularBatteryStatusWidget: Widget {
    let kind: String = "BatteryCircularWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(deviceSN: KeychainStore().getSelectedDeviceSN())) { entry in
            Group {
                if let soc = entry.soc {
                    BatteryGaugeView(value: soc, batteryPower: entry.batteryPower)
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
        .supportedFamilies([.accessoryCircular])
    }
}

struct CornerBatteryStatusWidget: Widget {
    let kind: String = "BatteryCornerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(deviceSN: KeychainStore().getSelectedDeviceSN())) { entry in
            Group {
                if let soc = entry.soc {
                    Text(soc, format: .percent)
                        .widgetLabel("SoC")
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
        .supportedFamilies([.accessoryCorner])
    }
}

struct RectangularBatteryStatusWidget: Widget {
    let kind: String = "BatteryCornerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(deviceSN: KeychainStore().getSelectedDeviceSN())) { entry in
            Group {
                if let soc = entry.soc {
                    HStack {
                        BatteryGaugeView(value: soc, batteryPower: entry.batteryPower)

//                        if let power = entry.batteryPower {
//                            HStack(alignment: .center) {
//                                Text("\(Image(systemName: power > 0 ? "square.and.arrow.down" : "square.and.arrow.up")) \(power.kW(2))")
//                                    .foregroundStyle(power.tintColor)
//                                    .font(.footnote)
//                            }
//                        }
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
            .containerBackground(for: .widget) {
                Color.clear
            }
        }
        .configurationDisplayName("Battery Status")
        .description("Shows the status of your home battery")
        .supportedFamilies([.accessoryRectangular, .accessoryInline])
    }
}

struct BatteryStatusWidget: Widget {
    let kind: String = "BatteryCornerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(deviceSN: KeychainStore().getSelectedDeviceSN())) { entry in
            Group {
                if let soc = entry.soc {
                    Text(soc, format: .percent)
                        .widgetLabel {
                            Image(systemName: "minus.plus.batteryblock.fill")
                                .font(.system(size: 14))
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
            .containerBackground(for: .widget) {
                Color.clear
            }
        }
        .configurationDisplayName("Battery Status")
        .description("Shows the status of your home battery")
        .supportedFamilies([.accessoryInline])
    }
}

#Preview("Rectangular", as: .accessoryRectangular) {
    RectangularBatteryStatusWidget()
} timeline: {
    SimpleEntry(date: .now, soc: 30, chargeStatusDescription: "Empty in 0 seconds", state: .loaded, errorMessage: nil, batteryPower: 2.0)
}

#Preview("Circular", as: .accessoryCircular) {
    CircularBatteryStatusWidget()
} timeline: {
    SimpleEntry(date: .now, soc: 30, chargeStatusDescription: "Empty in 0 seconds", state: .loaded, errorMessage: nil, batteryPower: 2.2)
}

#Preview("Inline", as: .accessoryInline) {
    BatteryStatusWidget()
} timeline: {
    SimpleEntry(date: .now, soc: 30, chargeStatusDescription: "Empty in 0 seconds", state: .loaded, errorMessage: nil, batteryPower: 2.2)
}

#Preview("Corner", as: .accessoryCorner) {
    CornerBatteryStatusWidget()
} timeline: {
    SimpleEntry(date: .now, soc: 30, chargeStatusDescription: "Empty in 0 seconds", state: .loaded, errorMessage: nil, batteryPower: 2.2)
}
