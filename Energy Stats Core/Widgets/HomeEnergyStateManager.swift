//
//  Intents.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 24/09/2023.
//

import AppIntents
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
@available(watchOS 9.0, *)
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
            modelContainer = try ModelContainer(for: BatteryWidgetState.self, StatsWidgetState.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }
}
