//
//  Config.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

public protocol Config {
    var isDemoUser: Bool { get set }
    var hasRunBefore: Bool { get set }
    var showColouredLines: Bool { get set }
    var showBatteryTemperature: Bool { get set }
    var showBatteryEstimate: Bool { get set }
    var refreshFrequency: Int { get set }
    var decimalPlaces: Int { get set }
    var showSunnyBackground: Bool { get set }
    var devices: Data? { get set }
    var selectedDeviceID: String? { get set }
    var showUsableBatteryOnly: Bool { get set }
    var displayUnit: Int { get set }
    var showTotalYield: Bool { get set }
    var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode { get set }
    var showEarnings: Bool { get set }
    var showInverterTemperature: Bool { get set }
    var selectedParameterGraphVariables: [String] { get set }
    var showHomeTotalOnPowerFlow: Bool { get set }
    var showInverterIcon: Bool { get set }
    var shouldInvertCT2: Bool { get set }
    var showInverterPlantName: Bool { get set }
    var showGridTotalsOnPowerFlow: Bool { get set }
    var showInverterTypeNameOnPowerFlow: Bool { get set }
    var deviceBatteryOverrides: [String: String] { get set }
    var showLastUpdateTimestamp: Bool { get set }
    var solarDefinitions: SolarRangeDefinitions { get set }
    var parameterGroups: [ParameterGroup] { get set }
}

extension UserDefaults {
    static var shared: UserDefaults {
        UserDefaults(suiteName: "group.com.alpriest.EnergyStats")!
    }
}

public class UserDefaultsConfig: Config {
    public init() {}

    private func bool(from source: UserDefaults, forKey key: String, defaultValue: Bool) -> Bool {
        (source.object(forKey: key) as? Bool) ?? defaultValue
    }

    private func integer(from source: UserDefaults, forKey key: String, defaultValue: Int) -> Int {
        (source.object(forKey: key) as? Int) ?? defaultValue
    }

    @UserDefaultsStoredBool(key: "hasRunBefore")
    public var hasRunBefore: Bool

    @UserDefaultsStoredBool(key: "isDemoUser")
    public var isDemoUser: Bool

    @UserDefaultsStoredBool(key: "showColouredLines", defaultValue: true)
    public var showColouredLines: Bool

    @UserDefaultsStoredBool(key: "showBatteryTemperature")
    public var showBatteryTemperature: Bool

    @UserDefaultsStoredBool(key: "showBatteryEstimate", defaultValue: true)
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

    @UserDefaultsStoredInt(key: "displayUnit")
    public var displayUnit: Int

    @UserDefaultsStoredBool(key: "showInverterTemperature", defaultValue: false)
    public var showInverterTemperature: Bool

    @UserDefaultsStoredBool(key: "showHomeTotal", defaultValue: false)
    public var showHomeTotalOnPowerFlow: Bool

    @UserDefaultsStoredBool(key: "showInverterIcon", defaultValue: true)
    public var showInverterIcon: Bool

    @UserDefaultsStoredBool(key: "shouldInvertCT2", defaultValue: true)
    public var shouldInvertCT2: Bool

    @UserDefaultsStoredBool(key: "showInverterPlantName", defaultValue: false)
    public var showInverterPlantName: Bool

    @UserDefaultsStoredBool(key: "showGridTotalsOnPowerFlow", defaultValue: false)
    public var showGridTotalsOnPowerFlow: Bool

    @UserDefaultsStoredBool(key: "showInverterTypeNameOnPowerFlow", defaultValue: false)
    public var showInverterTypeNameOnPowerFlow: Bool

    @UserDefaultsStoredBool(key: "showLastUpdateTimestamp", defaultValue: false)
    public var showLastUpdateTimestamp: Bool

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

    public var selectedParameterGraphVariables: [String] {
        get {
            UserDefaults.shared.array(forKey: "selectedParameterGraphVariables") as? [String] ?? []
        }
        set {
            UserDefaults.shared.set(newValue, forKey: "selectedParameterGraphVariables")
        }
    }

    public var deviceBatteryOverrides: [String: String] {
        get {
            UserDefaults.shared.dictionary(forKey: "deviceBatteryOverrides") as? [String: String] ?? [:]
        }
        set {
            UserDefaults.shared.set(newValue, forKey: "deviceBatteryOverrides")
        }
    }

    public var solarDefinitions: SolarRangeDefinitions {
        get {
            guard let solarDefinitions = UserDefaults.shared.data(forKey: "solarDefinitions") else { return .default() }
            do {
                return try JSONDecoder().decode(SolarRangeDefinitions.self, from: solarDefinitions)
            } catch {
                return .default()
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.shared.set(data, forKey: "solarDefinitions")
            } catch {
                print("AWP", "Failed to encode Solar Definitions 💥")
            }
        }
    }

    @UserDefaultsStoredCodable(key: "parameterGroups", defaultValue: DefaultParameterGroups())
    public var parameterGroups: [ParameterGroup]
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

@propertyWrapper
public struct UserDefaultsStoredCodable<T: Codable> {
    var key: String
    var defaultValue: T

    public var wrappedValue: T {
        get {
            guard let data = UserDefaults.shared.data(forKey: key) else {
                return defaultValue
            }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                return defaultValue
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.shared.set(data, forKey: key)
            } catch {
                print("AWP", "Failed to encode value for \(key) 💥")
            }
        }
    }
}

public func DefaultParameterGroups() -> [ParameterGroup] {
    [
        ParameterGroup(id: UUID(),
                       title: "Compare strings",
                       parameterNames: ["pvPower",
                                        "pv1Power",
                                        "pv2Power",
                                        "pv3Power",
                                        "pv4Power"]),
        ParameterGroup(id: UUID(),
                       title: "Temperatures",
                       parameterNames: ["ambientTemperation",
                                        "invTemperation",
                                        "batTemperature"]),
        ParameterGroup(id: UUID(),
                       title: "Battery",
                       parameterNames: ["batTemperature",
                                        "batVolt",
                                        "batCurrent",
                                        "SoC"])
    ]
}
