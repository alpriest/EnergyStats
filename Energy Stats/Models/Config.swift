//
//  Config.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

protocol Config {
    var minSOC: String? { get set }
    var batteryCapacity: String? { get set }
    var deviceID: String? { get set }
    var deviceSN: String? { get set }
    var hasBattery: Bool { get set }
    var hasPV: Bool { get set }
    var isDemoUser: Bool { get set }
    var showColouredLines: Bool { get set }
    var showBatteryTemperature: Bool { get set }
    var refreshFrequency: Int { get set }
    var decimalPlaces: Int { get set }
    var showSunnyBackground: Bool { get set }
}

class UserDefaultsConfig: Config {
    @UserDefaultsStoredString(key: "minSOC")
    var minSOC: String?

    @UserDefaultsStoredString(key: "batteryCapacity")
    var batteryCapacity: String?

    @UserDefaultsStoredString(key: "deviceID")
    var deviceID: String?

    @UserDefaultsStoredString(key: "deviceSN")
    var deviceSN: String?

    @UserDefaultsStoredBool(key: "hasBattery")
    var hasBattery: Bool

    @UserDefaultsStoredBool(key: "hasPV")
    var hasPV: Bool

    @UserDefaultsStoredBool(key: "isDemoUser")
    var isDemoUser: Bool

    @UserDefaultsStoredBool(key: "showColouredLines", defaultValue: true)
    var showColouredLines: Bool

    @UserDefaultsStoredBool(key: "showBatteryTemperature")
    var showBatteryTemperature: Bool

    @UserDefaultsStoredInt(key: "refreshFrequency")
    var refreshFrequency: Int

    @UserDefaultsStoredInt(key: "decimalPlaces", defaultValue: 3)
    var decimalPlaces: Int

    @UserDefaultsStoredBool(key: "showSunnyBackground", defaultValue: true)
    var showSunnyBackground: Bool
}

@propertyWrapper
struct UserDefaultsStoredInt {
    var key: String
    var defaultValue: Int = 0

    var wrappedValue: Int {
        get {
            (UserDefaults.standard.object(forKey: key) as? Int) ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct UserDefaultsStoredString {
    var key: String

    var wrappedValue: String? {
        get {
            UserDefaults.standard.string(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct UserDefaultsStoredBool {
    var key: String
    var defaultValue: Bool = false

    var wrappedValue: Bool {
        get {
            (UserDefaults.standard.object(forKey: key) as? Bool) ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
