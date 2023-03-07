//
//  Config.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

protocol Config {
    var isDemoUser: Bool { get set }
    var showColouredLines: Bool { get set }
    var showBatteryTemperature: Bool { get set }
    var refreshFrequency: Int { get set }
    var decimalPlaces: Int { get set }
    var showSunnyBackground: Bool { get set }
    var devices: Data? { get set }
}

class UserDefaultsConfig: Config {
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

    @UserDefaultsStoredData(key: "devices")
    var devices: Data?
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

@propertyWrapper
struct UserDefaultsStoredData {
    var key: String

    var wrappedValue: Data? {
        get {
            UserDefaults.standard.data(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
