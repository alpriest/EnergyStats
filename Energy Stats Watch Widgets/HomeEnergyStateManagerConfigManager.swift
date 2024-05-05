//
//  HomeEnergyStateManager.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 05/05/2024.
//

import Energy_Stats_Core
import Foundation

class HomeEnergyStateManagerConfigManager: HomeEnergyStateManagerConfig {
    private let keychainStore: KeychainStoring

    init(keychainStore: KeychainStoring = KeychainStore()) {
        self.keychainStore = keychainStore
    }

    @UserDefaultsStoredString(key: "batteryCapacity", defaultValue: "0")
    private var batteryCapacity: String

    var batteryCapacityW: Int {
        Int(batteryCapacity) ?? 0
    }

    @UserDefaultsStoredDouble(key: "minSOC")
    var minSOC: Double
    
    @UserDefaultsStoredBool(key: "showUsableBatteryOnly", defaultValue: false)
    var showUsableBatteryOnly: Bool
    
    var selectedDeviceSN: String? {
        keychainStore.getSelectedDeviceSN()
    }

    var dataCeiling: DataCeiling {
        .none
    }

    var isDemoUser: Bool {
        false
    }
}
