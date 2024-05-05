//
//  WatchConfigManager.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 05/05/2024.
//

import Energy_Stats_Core
import Foundation

protocol WatchConfigManaging: CurrentStatusCalculatorConfig, BatteryConfigManaging {}

class WatchConfigManager: WatchConfigManaging {
    @UserDefaultsStoredString(key: "batteryCapacity", defaultValue: "0")
    var batteryCapacity: String

    var batteryCapacityW: Int {
        Int(batteryCapacity) ?? 0
    }

    func clearBatteryOverride(for deviceID: String) {}

    @UserDefaultsStoredBool(key: "shouldInvertCT2", defaultValue: true)
    var shouldInvertCT2: Bool

    @UserDefaultsStoredBool(key: "shouldCombineCT2WithPVPower", defaultValue: true)
    var shouldCombineCT2WithPVPower: Bool

    var powerFlowStrings: PowerFlowStringsSettings = .none
}

class PreviewWatchConfig: WatchConfigManaging {
    var batteryCapacity: String = ""
    var batteryCapacityW: Int = 0
    func clearBatteryOverride(for deviceID: String) {}

    var shouldInvertCT2: Bool = false
    var shouldCombineCT2WithPVPower: Bool = false
    var powerFlowStrings: PowerFlowStringsSettings = .none
}
