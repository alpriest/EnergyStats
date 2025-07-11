//
//  HomeEnergyStateManager+GenerationStats.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/07/2025.
//

import AppIntents
import SwiftData
import WidgetKit

@available(iOS 17.0, *)
@available(watchOS 9.0, *)
extension HomeEnergyStateManager {
    @MainActor
    public func updateGenerationStatsState(config: HomeEnergyStateManagerConfig) async throws {
        guard await isGenerationStatsStateStale() else { return }
        guard let deviceSN = try config.selectedDeviceSN() else { throw ConfigManager.NoDeviceFoundError() }

        let result = try await network.fetchPowerGeneration(deviceSN: deviceSN)

        try store(model: result)
    }

    @MainActor
    public func isGenerationStatsStateStale() async -> Bool {
        let fetchDescriptor: FetchDescriptor<GenerationStatsWidgetState> = FetchDescriptor()
        guard let widgetState = (try? modelContainer.mainContext.fetch(fetchDescriptor))?.first else { return true }

        return widgetState.lastUpdated.timeIntervalSinceNow < -60
    }

    @MainActor
    private func store(model: PowerGenerationResponse) throws {
        let state = GenerationStatsWidgetState(
            today: model.today,
            month: model.month,
            cumulative: model.cumulative
        )

        deleteOldGenerationStatsStateEntries()

        modelContainer.mainContext.insert(state)
        modelContainer.mainContext.processPendingChanges()
    }

    @MainActor
    private func deleteOldGenerationStatsStateEntries() {
        let fetchDescriptor: FetchDescriptor<GenerationStatsWidgetState> = FetchDescriptor()
        do {
            for entry in try modelContainer.mainContext.fetch(fetchDescriptor) {
                modelContainer.mainContext.delete(entry)
            }
            try modelContainer.mainContext.save()
        } catch {
            print("AWP", "Could not delete entry")
        }
    }

}
