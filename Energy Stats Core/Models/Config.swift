//
//  Config.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

public protocol Config {
    var isDemoUser: Bool { get set }
    var showColouredLines: Bool { get set }
    var showBatteryTemperature: Bool { get set }
    var showBatteryEstimate: Bool { get set }
    var refreshFrequency: Int { get set }
    var decimalPlaces: Int { get set }
    var showSunnyBackground: Bool { get set }
    var devices: Data? { get set }
    var selectedDeviceID: String? { get set }
    var showUsableBatteryOnly: Bool { get set }
}

public class UserDefaultsConfig: Config {
    public init() {}

    @UserDefaultsStoredBool(key: "isDemoUser")
    public var isDemoUser: Bool

    @UserDefaultsStoredBool(key: "showColouredLines", defaultValue: true)
    public var showColouredLines: Bool

    @UserDefaultsStoredBool(key: "showBatteryTemperature")
    public var showBatteryTemperature: Bool

    @UserDefaultsStoredBool(key: "showBatteryEstimate")
    public var showBatteryEstimate: Bool

    @UserDefaultsStoredInt(key: "refreshFrequency")
    public var refreshFrequency: Int

    @UserDefaultsStoredInt(key: "decimalPlaces", defaultValue: 3)
    public var decimalPlaces: Int

    @UserDefaultsStoredBool(key: "showSunnyBackground", defaultValue: true)
    public var showSunnyBackground: Bool

    @UserDefaultsStoredBool(key: "showUsableBatteryOnly", defaultValue: false)
    public var showUsableBatteryOnly: Bool

    @UserDefaultsStoredData(key: "devices")
    public var devices: Data?

    @UserDefaultsStoredString(key: "selectedDeviceID")
    public var selectedDeviceID: String?
}

@propertyWrapper
public struct UserDefaultsStoredInt {
    var key: String
    var defaultValue: Int = 0

    public var wrappedValue: Int {
        get {
            (UserDefaults.standard.object(forKey: key) as? Int) ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultsStoredString {
    var key: String

    public var wrappedValue: String? {
        get {
            UserDefaults.standard.string(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultsStoredBool {
    var key: String
    var defaultValue: Bool = false

    public var wrappedValue: Bool {
        get {
            (UserDefaults.standard.object(forKey: key) as? Bool) ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultsStoredData {
    var key: String

    public var wrappedValue: Data? {
        get {
            UserDefaults.standard.data(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
