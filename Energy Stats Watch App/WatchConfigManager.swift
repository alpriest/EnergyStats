//
//  WatchConfigManager.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 05/05/2024.
//

import Combine
import Energy_Stats_Core
import Foundation

protocol WatchConfigManaging: CurrentStatusCalculatorConfig, BatteryConfigManager {
    var isLoggedInPublisher: AnyPublisher<Bool, Never> { get }
    var solarDefinitions: SolarRangeDefinitions { get }
    var deviceSN: String? { get }
    var apiKey: String? { get }
    var isLoggedIn: Bool { get }
}

class WatchConfigManager: WatchConfigManaging {
    var appSettingsPublisher: AnyPublisher<AppSettings, Never> = Just(.mock()).eraseToAnyPublisher()
    private let keychainStore: KeychainStoring

    private let _isLoggedInSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoggedInPublisher: AnyPublisher<Bool, Never> { _isLoggedInSubject.eraseToAnyPublisher() }

    init(keychainStore: KeychainStoring) {
        self.keychainStore = keychainStore
        _isLoggedInSubject.send(isLoggedIn)
    }

    var isLoggedIn: Bool {
        apiKey != nil && deviceSN != nil
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

    @UserDefaultsStoredOptionalString(key: "deviceSN")
    var deviceSN: String?

    @UserDefaultsStoredOptionalString(key: "apiKey")
    var apiKey: String?

    @UserDefaultsStoredBool(key: "showGridTotalsOnPowerFlow", defaultValue: false)
    var showGridTotalsOnPowerFlow: Bool

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
    
    func applyUpdatesThenNotify(_ apply: (WatchConfigManager) -> Void) {
        apply(self)
        _isLoggedInSubject.send(isLoggedIn)
    }
}

class PreviewWatchConfig: WatchConfigManaging {
    var appSettingsPublisher: AnyPublisher<AppSettings, Never> = Just(.mock()).eraseToAnyPublisher()
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

    var deviceSN: String? = "abc123"
    var apiKey: String? = "api123"
    var isLoggedIn: Bool = false
    var isLoggedInPublisher: AnyPublisher<Bool, Never> { Just(isLoggedIn).eraseToAnyPublisher() }
}
