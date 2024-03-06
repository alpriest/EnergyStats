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
        let store = InMemoryLoggingNetworkStore.shared
        let api = NetworkFacade(api: FoxAPIService(credentials: keychainStore, store: store),
                                config: config,
                                store: keychainStore)
        network = NetworkService(api: api)
        let appSettingsPublisher = AppSettingsPublisherFactory.make(from: config)
        configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher)
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
        var errorMessage: String? = nil

        do {
            try await HomeEnergyStateManager.shared.update()
        } catch _ as ConfigManager.NoBattery {
            return .failed(error: "Your selected inverter has no battery connected")
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            let fetchDescriptor: FetchDescriptor<BatteryWidgetState> = FetchDescriptor()
            if let widgetState = try (modelContainer.mainContext.fetch(fetchDescriptor)).first {
                return SimpleEntry.loaded(
                    date: widgetState.lastUpdated,
                    soc: widgetState.batterySOC,
                    chargeStatusDescription: widgetState.chargeStatusDescription,
                    errorMessage: errorMessage
                )
            } else {
                return .failed(error: errorMessage ?? "Could not fetch data")
            }
        } catch _ as ConfigManager.NoBattery {
            return .failed(error: "Your selected inverter has no battery connected")
        } catch {
            return .failed(error: "Could not load \(error.localizedDescription)")
        }
    }
}

enum EntryState: Equatable {
    case loaded
    case placeholder
    case failedWithoutData(reason: String)
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let soc: Int?
    let chargeStatusDescription: String?
    let state: EntryState
    let errorMessage: String?

    private init(date: Date, soc: Int?, chargeStatusDescription: String?, state: EntryState, errorMessage: String?) {
        self.date = date
        self.soc = soc
        self.state = state
        self.chargeStatusDescription = chargeStatusDescription
        self.errorMessage = errorMessage
    }

    static func loaded(date: Date, soc: Int, chargeStatusDescription: String?, errorMessage: String?) -> SimpleEntry {
        SimpleEntry(date: date,
                    soc: soc,
                    chargeStatusDescription: chargeStatusDescription,
                    state: .loaded,
                    errorMessage: nil)
    }

    static func placeholder() -> SimpleEntry {
        SimpleEntry(date: Date(),
                    soc: 87,
                    chargeStatusDescription: "Full in 25 minutes",
                    state: .placeholder,
                    errorMessage: nil)
    }

    static func failed(error: String) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    soc: nil,
                    chargeStatusDescription: nil,
                    state: .failedWithoutData(reason: error),
                    errorMessage: error)
    }
}
