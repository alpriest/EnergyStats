//
//  HomeEnergyStateManagerConfigAdapter.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 05/05/2024.
//

import Foundation

public class HomeEnergyStateManagerConfigAdapter: HomeEnergyStateManagerConfig {
    private let config: ConfigManaging
    private let keychainStore: KeychainStoring

    public init(config: ConfigManaging, keychainStore: KeychainStoring) {
        self.config = config
        self.keychainStore = keychainStore
    }

    public func batteryCapacityW() throws -> Int { try Int(keychainStore.get(key: .batteryCapacity) ?? 0.0) }

    public func minSOC() throws -> Double { try keychainStore.get(key: .minSOC) ?? 0.0 }

    public func showUsableBatteryOnly() throws -> Bool { try keychainStore.get(key: .showUsableBatteryOnly) }

    public func selectedDeviceSN() throws -> String? { try keychainStore.get(key: .deviceSN) }

    public func dataCeiling() throws -> DataCeiling { config.dataCeiling }

    public func isDemoUser() throws -> Bool { config.isDemoUser }
}
