//
//  WidgetEntryView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 14/06/2023.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Gauge(value: entry.soc) {
                Image(systemName: "minus.plus.batteryblock.fill")
                    .font(.system(size: 16))
            } currentValueLabel: {
                Text(entry.soc, format: .percent)
            }
            .gaugeStyle(.accessoryCircular)
        }
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(entry: SimpleEntry(date: Date(), soc: 0.80, grid: 2.0, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        WidgetEntryView(entry: SimpleEntry(date: Date(), soc: 0.80, grid: -2.0, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
