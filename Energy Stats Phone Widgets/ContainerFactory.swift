//
//  ContainerFactory.swift
//  
//
//  Created by Alistair Priest on 18/09/2025.
//

import Energy_Stats_Core
import SwiftData
import SwiftUI
import WidgetKit

enum ContainerFactory {
    private static func storeURL(fileName: String) -> URL {
        let base = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alpriest.EnergyStats")!
        return base.appendingPathComponent(fileName, conformingTo: .data)
    }

    static func makeBatteryStatsContainer() -> ModelContainer {
        do {
            let config = ModelConfiguration(url: storeURL(fileName: "BatteryStats.store"))
            return try ModelContainer(for: BatteryWidgetState.self, StatsWidgetState.self, configurations: config)
        } catch {
// Log if you can
#if DEBUG
            print("⚠️ SwiftData store failed, falling back to in-memory: \(error)")
#endif
            // In-memory fallback so @Query doesn’t crash
            let memCfg = ModelConfiguration(isStoredInMemoryOnly: true)
            return try! ModelContainer(for: BatteryWidgetState.self, StatsWidgetState.self,
                                       configurations: memCfg)
        }
    }
    
    static func makeGenerationStatsContainer() -> ModelContainer {
        do {
            let config = ModelConfiguration(url: storeURL(fileName: "GenerationStats.store"))
            return try ModelContainer(for: GenerationStatsWidgetState.self, configurations: config)
        } catch {
// Log if you can
#if DEBUG
            print("⚠️ SwiftData store failed, falling back to in-memory: \(error)")
#endif
            // In-memory fallback so @Query doesn’t crash
            let memCfg = ModelConfiguration(isStoredInMemoryOnly: true)
            return try! ModelContainer(for: GenerationStatsWidgetState.self, configurations: memCfg)
        }
    }
    
    static func makeStatsWidgetContainer() -> ModelContainer {
        do {
            let config = ModelConfiguration(url: storeURL(fileName: "StatsWidget.store"))
            return try ModelContainer(for: StatsWidgetState.self, configurations: config)
        } catch {
// Log if you can
#if DEBUG
            print("⚠️ SwiftData store failed, falling back to in-memory: \(error)")
#endif
            // In-memory fallback so @Query doesn’t crash
            let memCfg = ModelConfiguration(isStoredInMemoryOnly: true)
            return try! ModelContainer(for: StatsWidgetState.self, configurations: memCfg)
        }
    }
}
