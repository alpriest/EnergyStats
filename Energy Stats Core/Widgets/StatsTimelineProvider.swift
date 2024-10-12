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
            try await HomeEnergyStateManager.shared.updateTodayStatsState(config: config)
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            let fetchDescriptor: FetchDescriptor<StatsWidgetState> = FetchDescriptor()
            if let widgetState = try (modelContainer.mainContext.fetch(fetchDescriptor)).first {
                return StatsTimelineEntry.loaded(
                    date: .now,
                    home: widgetState.home,
                    gridImport: widgetState.gridImport,
                    gridExport: widgetState.gridExport,
                    batteryCharge: widgetState.batteryCharge,
                    batteryDischarge: widgetState.batteryDischarge,
                    totalHome: widgetState.totalHome,
                    totalGridImport: widgetState.totalGridImport,
                    totalGridExport: widgetState.totalGridExport,
                    totalBatteryCharge: widgetState.totalBatteryCharge,
                    totalBatteryDischarge: widgetState.totalBatteryDischarge,
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

@available(iOS 17.0, *)
public struct StatsTimelineEntry: TimelineEntry {
    public let date: Date
    public let gridImport: [Double]?
    public let gridExport: [Double]?
    public let home: [Double]?
    public let batteryCharge: [Double]?
    public let batteryDischarge: [Double]?
    public var totalHome: Double
    public var totalGridImport: Double
    public var totalGridExport: Double
    public var totalBatteryCharge: Double?
    public var totalBatteryDischarge: Double?
    public let state: EntryState
    public let errorMessage: String?

    public init(
        date: Date,
        home: [Double]?,
        gridImport: [Double]?,
        gridExport: [Double]?,
        batteryCharge: [Double]?,
        batteryDischarge: [Double]?,
        totalHome: Double,
        totalGridImport: Double,
        totalGridExport: Double,
        totalBatteryCharge: Double?,
        totalBatteryDischarge: Double?,
        state: EntryState,
        errorMessage: String?
    ) {
        self.date = date
        self.home = home
        self.gridImport = gridImport
        self.gridExport = gridExport
        self.batteryCharge = batteryCharge
        self.batteryDischarge = batteryDischarge
        self.totalHome = totalHome
        self.totalGridImport = totalGridImport
        self.totalGridExport = totalGridExport
        self.totalBatteryCharge = totalBatteryCharge
        self.totalBatteryDischarge = totalBatteryDischarge
        self.state = state
        self.errorMessage = errorMessage
    }

    public static func loaded(
        date: Date,
        home: [Double]?,
        gridImport: [Double]?,
        gridExport: [Double]?,
        batteryCharge: [Double]?,
        batteryDischarge: [Double]?,
        totalHome: Double,
        totalGridImport: Double,
        totalGridExport: Double,
        totalBatteryCharge: Double?,
        totalBatteryDischarge: Double?,
        errorMessage: String?
    ) -> StatsTimelineEntry {
        StatsTimelineEntry(date: date,
                           home: home,
                           gridImport: gridImport,
                           gridExport: gridExport,
                           batteryCharge: batteryCharge,
                           batteryDischarge: batteryDischarge,
                           totalHome: totalHome,
                           totalGridImport: totalGridImport,
                           totalGridExport: totalGridExport,
                           totalBatteryCharge: totalBatteryCharge,
                           totalBatteryDischarge: totalBatteryDischarge,
                           state: .loaded,
                           errorMessage: nil)
    }

    public static func placeholder() -> StatsTimelineEntry {
        StatsTimelineEntry(date: Date(),
                           home: StatsWidgetState.preview.home,
                           gridImport: StatsWidgetState.preview.gridImport,
                           gridExport: StatsWidgetState.preview.gridExport,
                           batteryCharge: StatsWidgetState.preview.batteryCharge,
                           batteryDischarge: StatsWidgetState.preview.batteryDischarge,
                           totalHome: 0,
                           totalGridImport: 0,
                           totalGridExport: 0,
                           totalBatteryCharge: nil,
                           totalBatteryDischarge: nil,
                           state: .placeholder,
                           errorMessage: nil)
    }

    public static func failed(error: String) -> StatsTimelineEntry {
        StatsTimelineEntry(date: Date(),
                           home: nil,
                           gridImport: nil,
                           gridExport: nil,
                           batteryCharge: nil,
                           batteryDischarge: nil,
                           totalHome: 0,
                           totalGridImport: 0,
                           totalGridExport: 0,
                           totalBatteryCharge: nil,
                           totalBatteryDischarge: nil,
                           state: .failedWithoutData(reason: error),
                           errorMessage: error)
    }
}
