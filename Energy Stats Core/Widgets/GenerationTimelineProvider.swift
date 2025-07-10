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
public struct GenerationStatsTimelineProvider: TimelineProvider {
    private let config: HomeEnergyStateManagerConfig
    private let keychainStore = KeychainStore()
    private let modelContainer: ModelContainer

    public init(config: HomeEnergyStateManagerConfig) {
        self.config = config
        modelContainer = HomeEnergyStateManager.shared.modelContainer
    }

    public func placeholder(in context: Context) -> GenerationStatsTimelineEntry {
        GenerationStatsTimelineEntry.placeholder()
    }

    public func getSnapshot(in context: Context, completion: @escaping (GenerationStatsTimelineEntry) -> ()) {
        if context.isPreview {
            let entry = GenerationStatsTimelineEntry.placeholder()
            completion(entry)
        } else {
            Task { @MainActor in
                let entry = await getCurrentState()
                completion(entry)
            }
        }
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<GenerationStatsTimelineEntry>) -> ()) {
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
    private func getCurrentState() async -> GenerationStatsTimelineEntry {
        var errorMessage: String? = nil

        do {
            try await HomeEnergyStateManager.shared.updateGenerationStatsState(config: config)
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            let fetchDescriptor: FetchDescriptor<GenerationStatsWidgetState> = FetchDescriptor()
            if let widgetState = try (modelContainer.mainContext.fetch(fetchDescriptor)).first {
                return GenerationStatsTimelineEntry.loaded(
                    date: .now,
                    today: widgetState.today,
                    month: widgetState.month,
                    cumulative: widgetState.cumulative,
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
public struct GenerationStatsTimelineEntry: TimelineEntry {
    public let date: Date
    public var today: Double?
    public var month: Double?
    public var cumulative: Double?
    public let state: EntryState
    public let errorMessage: String?

    public init(
        date: Date,
        today: Double?,
        month: Double?,
        cumulative: Double?,
        state: EntryState,
        errorMessage: String?
    ) {
        self.date = date
        self.today = today
        self.month = month
        self.cumulative = cumulative
        self.state = state
        self.errorMessage = errorMessage
    }

    public static func loaded(
        date: Date,
        today: Double,
        month: Double,
        cumulative: Double,
        errorMessage: String?
    ) -> GenerationStatsTimelineEntry {
        GenerationStatsTimelineEntry(date: date,
                                     today: today,
                                     month: month,
                                     cumulative: cumulative,
                                     state: .loaded,
                                     errorMessage: nil)
    }

    public static func placeholder() -> GenerationStatsTimelineEntry {
        GenerationStatsTimelineEntry(date: Date(),
                                     today: GenerationStatsWidgetState.preview.today,
                                     month: GenerationStatsWidgetState.preview.month,
                                     cumulative: GenerationStatsWidgetState.preview.cumulative,
                                     state: .placeholder,
                                     errorMessage: nil)
    }

    public static func failed(error: String) -> GenerationStatsTimelineEntry {
        GenerationStatsTimelineEntry(date: Date(),
                                     today: nil,
                                     month: nil,
                                     cumulative: nil,
                                     state: .failedWithoutData(reason: error),
                                     errorMessage: error)
    }
}
