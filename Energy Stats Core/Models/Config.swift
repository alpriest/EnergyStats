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
    var showInW: Bool { get set }
    var showTotalYield: Bool { get set }
    var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode { get set }
    var showEarnings: Bool { get set }
}

extension UserDefaults {
    static var shared: UserDefaults {
        UserDefaults(suiteName: "group.com.alpriest.EnergyStats")!
    }
}

public class UserDefaultsConfig: Config {
    public init() {
        let suiteDefaults = UserDefaults.shared
        let defaults = UserDefaults.standard

        if defaults.data(forKey: "devices") != nil && suiteDefaults.data(forKey: "devices") == nil {
            migrate(from: defaults, to: suiteDefaults)
        }
    }

    func migrate(from source: UserDefaults, to destination: UserDefaults) {
        destination.set(source.bool(forKey: "isDemoUser"), forKey: "isDemoUser")
        destination.set(bool(from: source, forKey: "showColouredLines", defaultValue: true), forKey: "showColouredLines")
        destination.set(source.bool(forKey: "showBatteryTemperature"), forKey: "showBatteryTemperature")
        destination.set(source.bool(forKey: "showBatteryEstimate"), forKey: "showBatteryEstimate")
        destination.set(source.integer(forKey: "refreshFrequency"), forKey: "refreshFrequency")
        destination.set(integer(from: source, forKey: "decimalPlaces", defaultValue: 3), forKey: "decimalPlaces")
        destination.set(bool(from: source, forKey: "showSunnyBackground", defaultValue: true), forKey: "showSunnyBackground")
        destination.set(source.bool(forKey: "showUsableBatteryOnly"), forKey: "showUsableBatteryOnly")
        destination.set(bool(from: source, forKey: "showTotalYield", defaultValue: true), forKey: "showTotalYield")
        destination.set(source.data(forKey: "devices"), forKey: "devices")
        destination.set(source.string(forKey: "selectedDeviceID"), forKey: "selectedDeviceID")
        destination.set(source.bool(forKey: "showInW"), forKey: "showInW")

        source.removeObject(forKey: "isDemoUser")
        source.removeObject(forKey: "showColouredLines")
        source.removeObject(forKey: "showBatteryTemperature")
        source.removeObject(forKey: "showBatteryEstimate")
        source.removeObject(forKey: "refreshFrequency")
        source.removeObject(forKey: "decimalPlaces")
        source.removeObject(forKey: "showSunnyBackground")
        source.removeObject(forKey: "showUsableBatteryOnly")
        source.removeObject(forKey: "showTotalYield")
        source.removeObject(forKey: "devices")
        source.removeObject(forKey: "selectedDeviceID")
        source.removeObject(forKey: "showInW")
    }

    private func bool(from source: UserDefaults, forKey key: String, defaultValue: Bool) -> Bool {
        (source.object(forKey: key) as? Bool) ?? defaultValue
    }

    private func integer(from source: UserDefaults, forKey key: String, defaultValue: Int) -> Int {
        (source.object(forKey: key) as? Int) ?? defaultValue
    }

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

    @UserDefaultsStoredBool(key: "showTotalYield", defaultValue: false)
    public var showTotalYield: Bool

    @UserDefaultsStoredData(key: "devices")
    public var devices: Data?

    @UserDefaultsStoredString(key: "selectedDeviceID")
    public var selectedDeviceID: String?

    @UserDefaultsStoredBool(key: "showInW", defaultValue: true)
    public var showInW: Bool

    public var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode {
        get {
            let rawValue = UserDefaults.shared.integer(forKey: "selfSufficiencyEstimateMode")
            return SelfSufficiencyEstimateMode(rawValue: rawValue) ?? .off
        }
        set {
            UserDefaults.shared.set(newValue.rawValue, forKey: "selfSufficiencyEstimateMode")
        }
    }

    @UserDefaultsStoredBool(key: "showEarnings", defaultValue: false)
    public var showEarnings: Bool
}

@propertyWrapper
public struct UserDefaultsStoredInt {
    var key: String
    var defaultValue: Int = 0

    public var wrappedValue: Int {
        get {
            (UserDefaults.shared.object(forKey: key) as? Int) ?? defaultValue
        }
        set {
            UserDefaults.shared.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultsStoredString {
    var key: String

    public var wrappedValue: String? {
        get {
            UserDefaults.shared.string(forKey: key)
        }
        set {
            UserDefaults.shared.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultsStoredBool {
    var key: String
    var defaultValue: Bool = false

    public var wrappedValue: Bool {
        get {
            (UserDefaults.shared.object(forKey: key) as? Bool) ?? defaultValue
        }
        set {
            UserDefaults.shared.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultsStoredData {
    var key: String

    public var wrappedValue: Data? {
        get {
            UserDefaults.shared.data(forKey: key)
        }
        set {
            UserDefaults.shared.set(newValue, forKey: key)
        }
    }
}
