//
//  Provider.swift
//  Widget
//
//  Created by Alistair Priest on 14/06/2023.
//

import Intents
import SwiftData
import SwiftUI
import WidgetKit

@available(iOS 17.0, *)
public struct BatteryTimelineProvider: TimelineProvider {
    private let config: HomeEnergyStateManagerConfig
    private let keychainStore = KeychainStore()
    private let modelContainer: ModelContainer

    public init(config: HomeEnergyStateManagerConfig) {
        self.config = config
        modelContainer = HomeEnergyStateManager.shared.modelContainer
    }

    public func placeholder(in context: Context) -> BatteryTimelineEntry {
        BatteryTimelineEntry.placeholder()
    }

    public func getSnapshot(in context: Context, completion: @escaping (BatteryTimelineEntry) -> ()) {
        if context.isPreview {
            let entry = BatteryTimelineEntry.placeholder()
            completion(entry)
        } else {
            Task { @MainActor in
                let entry = await getCurrentState()
                completion(entry)
            }
        }
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<BatteryTimelineEntry>) -> ()) {
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
    private func getCurrentState() async -> BatteryTimelineEntry {
        var errorMessage: String? = nil

        do {
            try await HomeEnergyStateManager.shared.updateBatteryState(config: config)
        } catch _ as ConfigManager.NoBattery {
            return .failed(error: "Your selected inverter has no battery connected")
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            let fetchDescriptor: FetchDescriptor<BatteryWidgetState> = FetchDescriptor()
            if let widgetState = try (modelContainer.mainContext.fetch(fetchDescriptor)).first {
                return BatteryTimelineEntry.loaded(
                    date: widgetState.lastUpdated,
                    soc: widgetState.batterySOC,
                    chargeStatusDescription: widgetState.chargeStatusDescription,
                    errorMessage: errorMessage,
                    batteryPower: widgetState.batteryPower
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

public enum EntryState: Equatable {
    case loaded
    case placeholder
    case failedWithoutData(reason: String)
}

public struct BatteryTimelineEntry: TimelineEntry {
    public let date: Date
    public let soc: Int?
    public let chargeStatusDescription: String?
    public let state: EntryState
    public let errorMessage: String?
    public let batteryPower: Double?

    public init(date: Date, soc: Int?, chargeStatusDescription: String?, state: EntryState, errorMessage: String?, batteryPower: Double?) {
        self.date = date
        self.soc = soc
        self.state = state
        self.chargeStatusDescription = chargeStatusDescription
        self.errorMessage = errorMessage
        self.batteryPower = batteryPower
    }

    public static func loaded(date: Date, soc: Int, chargeStatusDescription: String?, errorMessage: String?, batteryPower: Double?) -> BatteryTimelineEntry {
        BatteryTimelineEntry(date: date,
                    soc: soc,
                    chargeStatusDescription: chargeStatusDescription,
                    state: .loaded,
                    errorMessage: nil,
                    batteryPower: batteryPower)
    }

    public static func placeholder() -> BatteryTimelineEntry {
        BatteryTimelineEntry(date: Date(),
                    soc: 87,
                    chargeStatusDescription: "Full in 25 minutes",
                    state: .placeholder,
                    errorMessage: nil,
                    batteryPower: nil)
    }

    public static func failed(error: String) -> BatteryTimelineEntry {
        BatteryTimelineEntry(date: Date(),
                    soc: nil,
                    chargeStatusDescription: nil,
                    state: .failedWithoutData(reason: error),
                    errorMessage: error,
                    batteryPower: nil)
    }
}
