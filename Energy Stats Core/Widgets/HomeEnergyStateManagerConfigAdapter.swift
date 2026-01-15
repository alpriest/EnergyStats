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

    public func batteryCapacityW() throws -> Int { config.batteryCapacityW }
    
    public func minSOC() throws -> Double { config.minSOC }

    public func showUsableBatteryOnly() throws -> Bool { config.showUsableBatteryOnly }

    public func selectedDeviceSN() throws -> String? { config.selectedDeviceSN }

    public func dataCeiling() throws -> DataCeiling { config.dataCeiling }

    public func isDemoUser() throws -> Bool { config.isDemoUser }
}
