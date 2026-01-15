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

    public func batteryCapacityW() -> Int { config.batteryCapacityW }
    
    public func minSOC() -> Double { config.minSOC }

    public func showUsableBatteryOnly() -> Bool { config.showUsableBatteryOnly }

    public func selectedDeviceSN() -> String? { config.selectedDeviceSN }

    public func dataCeiling() -> DataCeiling { config.dataCeiling }

    public func isDemoUser() -> Bool { config.isDemoUser }
}
