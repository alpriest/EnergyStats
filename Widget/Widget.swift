//
//  Widget.swift
//  Widget
//
//  Created by Alistair Priest on 14/06/2023.
//

import Energy_Stats_Core
import Intents
import SwiftUI
import WidgetKit

struct Provider: IntentTimelineProvider {
    private let config = UserDefaultsConfig()
    private let configManager: ConfigManaging
    private let keychainStore = KeychainStore()
    let network: Networking

    init() {
        let store = InMemoryLoggingNetworkStore()
        network = NetworkFacade(network: Network(credentials: keychainStore, config: config, store: store),
                                config: config)
        configManager = ConfigManager(networking: network, config: config)
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.empty(configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        if context.isPreview {
            let entry = SimpleEntry(date: Date(), soc: 0.63, grid: 2.0, home: 0.342, solar: 3.21, configuration: configuration)
            completion(entry)
        } else {
            Task {
                let entry = await getCurrentState(for: configuration)
                completion(entry)
            }
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        Task {
            let entry = await getCurrentState(for: configuration)

            // Create a date that's 5 minutes in the future.
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: entry.date)!

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

    private func getCurrentState(for configuration: ConfigurationIntent) async -> SimpleEntry {
        guard let deviceID = config.selectedDeviceID,
              let battery = try? await network.fetchBattery(deviceID: deviceID) 
        else { return SimpleEntry.empty(configuration: configuration) }

        let date = Date()
        let entry = SimpleEntry(
            date: date,
            soc: Double(battery.soc) / 100.0,
            grid: 2.0, // TODO: Fetch from server
            home: 0.8, // TODO: Fetch from server
            solar: 2.34, // TODO: Fetch from server
            configuration: configuration
        )

        return entry
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var battery: Double = 0.0
    var soc: Double
    var grid: Double = 0.0
    var home: Double = 0.0
    var solar: Double = 0.0
    let configuration: ConfigurationIntent

    static func empty(configuration: ConfigurationIntent) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    battery: 0.0,
                    soc: 0,
                    grid: 0.0,
                    home: 0.0,
                    solar: 0.0,
                    configuration: configuration)
    }
}

