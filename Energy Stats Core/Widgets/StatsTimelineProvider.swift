//
//  StatsTimelineProvider.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/10/2024.
//

import Intents
import SwiftData
import SwiftUI
import WidgetKit

@available(iOS 17.0, *)
public struct StatsTimelineProvider: TimelineProvider {
    private let config: HomeEnergyStateManagerConfig
    private let keychainStore = KeychainStore()
    private let modelContainer: ModelContainer

    public init(config: HomeEnergyStateManagerConfig) {
        self.config = config
        modelContainer = HomeEnergyStateManager.shared.modelContainer
    }

    public func placeholder(in context: Context) -> StatsTimelineEntry {
        StatsTimelineEntry.placeholder()
    }

    public func getSnapshot(in context: Context, completion: @escaping (StatsTimelineEntry) -> ()) {
        if context.isPreview {
            let entry = StatsTimelineEntry.placeholder()
            completion(entry)
        } else {
            Task { @MainActor in
                let entry = await getCurrentState()
                completion(entry)
            }
        }
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<StatsTimelineEntry>) -> ()) {
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
    private func getCurrentState() async -> StatsTimelineEntry {
        var errorMessage: String? = nil

        do {
            try await HomeEnergyStateManager.shared.updateStatsState(config: config)
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            let fetchDescriptor: FetchDescriptor<StatsWidgetState> = FetchDescriptor()
            if let widgetState = try (modelContainer.mainContext.fetch(fetchDescriptor)).first {
                return StatsTimelineEntry.loaded(
                    date: .now,
                    gridImport: widgetState.gridImport,
                    gridExport: widgetState.gridExport,
                    home: widgetState.home,
                    batteryCharge: widgetState.batteryCharge,
                    batteryDischarge: widgetState.batteryDischarge,
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

public struct StatsTimelineEntry: TimelineEntry {
    public let date: Date
    public let gridImport: Double?
    public let gridExport: Double?
    public let home: Double?
    public let batteryCharge: Double?
    public let batteryDischarge: Double?
    public let state: EntryState
    public let errorMessage: String?

    public init(
        date: Date,
        gridImport: Double?,
        gridExport: Double?,
        home: Double?,
        batteryCharge: Double?,
        batteryDischarge: Double?,
        state: EntryState,
        errorMessage: String?
    ) {
        self.date = date
        self.gridImport = gridImport
        self.gridExport = gridExport
        self.home = home
        self.batteryCharge = batteryCharge
        self.batteryDischarge = batteryDischarge
        self.state = state
        self.errorMessage = errorMessage
    }

    public static func loaded(date: Date, gridImport: Double?, gridExport: Double?, home: Double?, batteryCharge: Double?, batteryDischarge: Double?, errorMessage: String?) -> StatsTimelineEntry {
        StatsTimelineEntry(date: date,
                           gridImport: gridImport,
                           gridExport: gridExport,
                           home: home,
                           batteryCharge: batteryCharge,
                           batteryDischarge: batteryDischarge,
                           state: .loaded,
                           errorMessage: nil)
    }

    public static func placeholder() -> StatsTimelineEntry {
        StatsTimelineEntry(date: Date(),
                           gridImport: 1.4,
                           gridExport: 0.0,
                           home: 3.2,
                           batteryCharge: 0.0,
                           batteryDischarge: 0,
                           state: .placeholder,
                           errorMessage: nil)
    }

    public static func failed(error: String) -> StatsTimelineEntry {
        StatsTimelineEntry(date: Date(),
                           gridImport: nil,
                           gridExport: nil,
                           home: nil,
                           batteryCharge: nil,
                           batteryDischarge: nil,
                           state: .failedWithoutData(reason: error),
                           errorMessage: error)
    }
}
