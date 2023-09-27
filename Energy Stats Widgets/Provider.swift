//
//  Provider.swift
//  Widget
//
//  Created by Alistair Priest on 14/06/2023.
//

import Energy_Stats_Core
import Intents
import SwiftData
import SwiftUI
import WidgetKit

public final class BundleLocator {}

struct Provider: TimelineProvider {
    private let config = UserDefaultsConfig()
    private let configManager: ConfigManaging
    private let keychainStore = KeychainStore()
    let network: Networking
    private let modelContainer: ModelContainer

    init() {
        let store = InMemoryLoggingNetworkStore()
        network = NetworkFacade(network: Network(credentials: keychainStore, store: store),
                                config: config,
                                store: keychainStore)
        configManager = ConfigManager(networking: network, config: config)
        modelContainer = HomeEnergyStateManager.shared.modelContainer
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        if context.isPreview {
            let entry = SimpleEntry.placeholder()
            completion(entry)
        } else {
            Task { @MainActor in
                let entry = await getCurrentState()
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        Task { @MainActor in
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

    @MainActor
    private func getCurrentState() async -> SimpleEntry {
        do {
            try await HomeEnergyStateManager.shared.update()

            let fetchDescriptor: FetchDescriptor<BatteryWidgetState> = FetchDescriptor()
            if let widgetState = try (modelContainer.mainContext.fetch(fetchDescriptor)).first {
                return SimpleEntry.loaded(soc: widgetState.batterySOC, chargeStatusDescription: widgetState.chargeStatusDescription)
            } else {
                return .failed(error: "Could not load from CoreData")
            }
        } catch {
            return .failed(error: "Could not load \(error.localizedDescription)")
        }
    }
}

enum EntryState: Equatable {
    case loaded
    case placeholder
    case failed(reason: String)
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let soc: Int
    let chargeStatusDescription: String?
    let state: EntryState

    private init(date: Date, soc: Int, chargeStatusDescription: String?, state: EntryState) {
        self.date = date
        self.soc = soc
        self.state = state
        self.chargeStatusDescription = chargeStatusDescription
    }

    static func loaded(soc: Int, chargeStatusDescription: String?) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    soc: soc,
                    chargeStatusDescription: chargeStatusDescription,
                    state: .loaded)
    }

    static func placeholder() -> SimpleEntry {
        SimpleEntry(date: Date(),
                    soc: 0,
                    chargeStatusDescription: nil,
                    state: .placeholder)
    }

    static func failed(error: String) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    soc: 0,
                    chargeStatusDescription: nil,
                    state: .failed(reason: error))
    }
}
