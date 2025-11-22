//
//  Intents.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 24/09/2023.
//

import AppIntents
import OSLog
import SwiftData
import WidgetKit

public protocol HomeEnergyStateManagerConfig {
    func batteryCapacityW() throws -> Int
    func minSOC() throws -> Double
    func showUsableBatteryOnly() throws -> Bool
    func selectedDeviceSN() throws -> String?
    func dataCeiling() throws -> DataCeiling
    func isDemoUser() throws -> Bool
}

@available(iOS 17.0, *)
@available(watchOS 10.0, *)
public class HomeEnergyStateManager {
    public static var shared: HomeEnergyStateManager = .init()

    public let modelContainer: ModelContainer
    let network: Networking
    let keychainStore = KeychainStore()

    init() {
        do {
            network = NetworkService.standard(keychainStore: keychainStore,
                                              urlSession: URLSession.shared,
                                              isDemoUser: { false },
                                              dataCeiling: { .none })
            modelContainer = try ModelContainer(for: BatteryWidgetState.self, StatsWidgetState.self, GenerationStatsWidgetState.self)
        } catch {
            // Log everything we can
            let ns = error as NSError
            Logger(subsystem: "EnergyStats", category: "SwiftData")
                .error("ModelContainer init failed: \(ns.localizedDescription, privacy: .public) (\(ns.domain, privacy: .public)) code=\(ns.code, privacy: .public) userInfo=\(ns.userInfo as NSDictionary, privacy: .public)")

            // In debug, crash loudly with details. In release, fall back to in-memory so the app keeps working.
            #if DEBUG
            fatalError("ModelContainer failed: \(error)")
            #else
            modelContainer = try! ModelContainer(
                for: BatteryWidgetState.self, StatsWidgetState.self, GenerationStatsWidgetState.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            #endif
        }
    }
}
