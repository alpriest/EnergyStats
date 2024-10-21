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

    public var batteryCapacityW: Int { Int(keychainStore.get(key: .batteryCapacity) ?? 0.0) }

    public var minSOC: Double { keychainStore.get(key: .minSOC) ?? 0.0 }

    public var showUsableBatteryOnly: Bool { keychainStore.get(key: .showUsableBatteryOnly) }

    public var selectedDeviceSN: String? { keychainStore.get(key: .deviceSN) }

    public var dataCeiling: DataCeiling { config.dataCeiling }

    public var isDemoUser: Bool { config.isDemoUser }
}
