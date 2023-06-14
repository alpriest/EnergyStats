//
//  Widget.swift
//  Widget
//
//  Created by Alistair Priest on 14/06/2023.
//

import Intents
import SwiftUI
import WidgetKit
import Energy_Stats_Core

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), soc: 0.80, grid: 2.0, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), soc: 0.80, grid: 2.0, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let date = Date()
        let entry = SimpleEntry(
            date: date,
            soc: 0.80, // TODO Fetch from server
            grid: 2.0, // TODO Fetch from server
            configuration: configuration
        )

        // Create a date that's 15 minutes in the future.
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: date)!

        // Create the timeline with the entry and a reload policy with the date
        // for the next update.
        let timeline = Timeline(
            entries: [entry],
            policy: .after(nextUpdateDate)
        )

        // Call the completion to pass the timeline to WidgetKit.
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var soc: Double = 0.0
    var grid: Double = 0.0
    let configuration: ConfigurationIntent
}

struct EnergyStatsWidget: Widget {
    let kind: String = "EnergyStatsWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Battery Level")
        .description("The percentage of the battery capacity that is available")
    }
}
