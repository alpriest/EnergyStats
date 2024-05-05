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

    public var batteryCapacityW: Int { config.batteryCapacityW }

    public var minSOC: Double { config.minSOC }

    public var showUsableBatteryOnly: Bool { config.showUsableBatteryOnly }

    public var selectedDeviceSN: String? { config.selectedDeviceSN }

    public var dataCeiling: DataCeiling { config.dataCeiling }

    public var isDemoUser: Bool { config.isDemoUser }
}
