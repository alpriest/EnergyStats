//
//  HomeEnergyStateManagerConfigAdapter.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 05/05/2024.
//

import Foundation

public class HomeEnergyStateManagerConfigAdapter: HomeEnergyStateManagerConfig {
    private let config: ConfigManaging

    public init(config: ConfigManaging) {
        self.config = config
    }

    public func batteryCapacityW() -> Int { config.batteryCapacityW }
    
    public func minSOC() -> Double { config.minSOC }

    public func showUsableBatteryOnly() -> Bool { config.showUsableBatteryOnly }

    public func selectedDeviceSN() -> String? { config.selectedDeviceSN }

    public func dataCeiling() -> DataCeiling { config.dataCeiling }

    public func isDemoUser() -> Bool { config.isDemoUser }
}
