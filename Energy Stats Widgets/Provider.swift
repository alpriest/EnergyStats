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

struct Provider: TimelineProvider {
    private let config = UserDefaultsConfig()
    private let configManager: ConfigManaging
    private let keychainStore = KeychainStore()
    let network: Networking

    init() {
        let store = InMemoryLoggingNetworkStore()
        network = NetworkFacade(network: Network(credentials: keychainStore, store: store),
                                config: config,
                                store: keychainStore)
        configManager = ConfigManager(networking: network, config: config)
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        if context.isPreview {
            let entry = SimpleEntry.placeholder()
            completion(entry)
        } else {
            Task {
                let entry = await getCurrentState()
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        Task {
            let entry = await getCurrentState()

            // Create a date that's 60 minutes in the future.
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 60, to: entry.date)!

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

    private func getCurrentState() async -> SimpleEntry {
        do {
            try await HomeEnergyStateManager.shared.update()

            return .loaded(soc: HomeEnergyStateManager.shared.batterySOC, chargeStatusDescription: HomeEnergyStateManager.shared.chargeStatusDescription)
        } catch {
            return .failed(error: "Could not load \(error.localizedDescription)")
        }
    }
}

enum EntryState {
    case loaded
    case placeholder
    case failed
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let soc: Int
    let chargeStatusDescription: String?
    let error: String?
    let state: EntryState

    private init(date: Date, soc: Int, chargeStatusDescription: String?, error: String?, state: EntryState) {
        self.date = date
        self.soc = soc
        self.error = error
        self.state = state
        self.chargeStatusDescription = chargeStatusDescription
    }

    static func loaded(soc: Int, chargeStatusDescription: String?) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    soc: soc,
                    chargeStatusDescription: chargeStatusDescription,
                    error: nil,
                    state: .loaded)
    }

    static func placeholder() -> SimpleEntry {
        SimpleEntry(date: Date(),
                    soc: 0,
                    chargeStatusDescription: nil,
                    error: nil,
                    state: .placeholder)
    }

    static func failed(error: String) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    soc: 0,
                    chargeStatusDescription: nil,
                    error: error,
                    state: .failed)
    }
}
