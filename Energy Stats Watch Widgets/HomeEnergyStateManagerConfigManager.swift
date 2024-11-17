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

    func batteryCapacityW() -> Int {
        Int(batteryCapacity) ?? 0
    }

    func minSOC() -> Double {
        UserDefaultsStoredDouble(key: "minSOC").wrappedValue
    }


    func showUsableBatteryOnly() -> Bool {
        UserDefaultsStoredBool(key: "showUsableBatteryOnly", defaultValue: false).wrappedValue
    }

    func selectedDeviceSN() -> String? {
        try? keychainStore.get(key: .deviceSN)
    }

    func dataCeiling() -> DataCeiling {
        .none
    }

    func isDemoUser() -> Bool {
        false
    }
}
