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
    var appSettingsPublisher: LatestAppSettingsPublisher = .init(.mock())
    private let keychainStore: KeychainStoring
    
    init(keychainStore: KeychainStoring) {
        self.keychainStore = keychainStore
    }
    
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
    
    @UserDefaultsStoredBool(key: "shouldCombineCT2WithLoadsPower", defaultValue: false)
    var shouldCombineCT2WithLoadsPower: Bool
    
    var powerFlowStrings: PowerFlowStringsSettings = .none
    
    @UserDefaultsStoredDouble(key: "minSOC")
    var minSOC: Double
    
    @UserDefaultsStoredBool(key: "showUsableBatteryOnly", defaultValue: false)
    var showUsableBatteryOnly: Bool
    
    var showGridTotalsOnPowerFlow: Bool {
        get {
            (try? keychainStore.get(key: .showGridTotalsOnPowerFlow)) ?? false
        }
        set {
            try? keychainStore.store(key: .showGridTotalsOnPowerFlow, value: newValue)
        }
    }
    
    var solarDefinitions: SolarRangeDefinitions {
        get {
            guard let solarDefinitions = UserDefaults.shared.data(forKey: "solarDefinitions") else { return .default }
            do {
                return try JSONDecoder().decode(SolarRangeDefinitions.self, from: solarDefinitions)
            } catch {
                return .default
            }
        }
        set {
            UserDefaults.shared.set(newValue, forKey: "solarDefinitions")
        }
    }
    
    @UserDefaultsStoredBool(key: "allowNegativeLoad", defaultValue: false)
    var allowNegativeLoad: Bool
}

class PreviewWatchConfig: WatchConfigManaging {
    var appSettingsPublisher: LatestAppSettingsPublisher = .init(.mock())
    var batteryCapacity: String = ""
    var batteryCapacityW: Int = 0
    func clearBatteryOverride(for deviceID: String) {}

    var shouldInvertCT2: Bool = false
    var shouldCombineCT2WithPVPower: Bool = false
    var powerFlowStrings: PowerFlowStringsSettings = .none
    var minSOC: Double = 0.0
    var showUsableBatteryOnly: Bool = false
    var showGridTotalsOnPowerFlow: Bool = true
    var solarDefinitions: SolarRangeDefinitions = .default
    var shouldCombineCT2WithLoadsPower: Bool = false
    var allowNegativeLoad: Bool = false
}
