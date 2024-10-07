//
//  WatchConfigManager.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 05/05/2024.
//

import Energy_Stats_Core
import Foundation

protocol WatchConfigManaging: CurrentStatusCalculatorConfig, BatteryConfigManager {
    var solarDefinitions: SolarRangeDefinitions { get }
}

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

    @UserDefaultsStoredDouble(key: "minSOC")
    var minSOC: Double

    @UserDefaultsStoredBool(key: "showUsableBatteryOnly", defaultValue: false)
    var showUsableBatteryOnly: Bool

    @UserDefaultsStoredBool(key: "showGridTotalsOnPowerFlow", defaultValue: false)
    var showGridTotalsOnPowerFlow: Bool

    var solarDefinitions: SolarRangeDefinitions {
        get {
            guard let solarDefinitions = UserDefaults.shared.data(forKey: "solarDefinitions") else { return .default() }
            do {
                return try JSONDecoder().decode(SolarRangeDefinitions.self, from: solarDefinitions)
            } catch {
                return .default()
            }
        }
        set {
            UserDefaults.shared.set(newValue, forKey: "solarDefinitions")
        }
    }
}

class PreviewWatchConfig: WatchConfigManaging {
    var batteryCapacity: String = ""
    var batteryCapacityW: Int = 0
    func clearBatteryOverride(for deviceID: String) {}

    var shouldInvertCT2: Bool = false
    var shouldCombineCT2WithPVPower: Bool = false
    var powerFlowStrings: PowerFlowStringsSettings = .none
    var minSOC: Double = 0.0
    var showUsableBatteryOnly: Bool = false
    var showGridTotalsOnPowerFlow: Bool = true
    var solarDefinitions: SolarRangeDefinitions = .default()
}
