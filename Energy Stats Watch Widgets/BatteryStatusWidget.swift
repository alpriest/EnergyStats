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

    var body: some WidgetConfiguration {
//        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
        StaticConfiguration(kind: kind, provider: Provider(deviceSN: KeychainStore().getSelectedDeviceSN())) { entry in
            Group {
                if let soc = entry.soc {
                    Text(soc, format: .percent)
                        .widgetLabel("SOC")
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
                            .accessoryRectangular])
    }
}

#Preview(as: .accessoryCorner) {
    BatteryStatusWidget()
} timeline: {
    SimpleEntry(date: .now, soc: 25, chargeStatusDescription: "S", state: .loaded, errorMessage: nil)
}
