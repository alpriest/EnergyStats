//
//  Config.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

public protocol Config {
    func clear()
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
    var showFinancialEarnings: Bool { get set }
    var financialModel: Int { get set }
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
    var feedInUnitPrice: Double { get set }
    var gridImportUnitPrice: Double { get set }
    var currencySymbol: String { get set }
    var shouldCombineCT2WithPVPower: Bool { get set }
    var showGraphValueDescriptions: Bool { get set }
}

extension UserDefaults {
    static var shared: UserDefaults {
        UserDefaults(suiteName: "group.com.alpriest.EnergyStats")!
    }
}

public class UserDefaultsConfig: Config {
    public init() {}

    public func clear() {
        UserDefaults.shared.removeObject(forKey: "showGraphValueDescriptions")
        UserDefaults.shared.removeObject(forKey: "hasRunBefore")
        UserDefaults.shared.removeObject(forKey: "isDemoUser")
        UserDefaults.shared.removeObject(forKey: "showColouredLines")
        UserDefaults.shared.removeObject(forKey: "showBatteryTemperature")
        UserDefaults.shared.removeObject(forKey: "showBatteryEstimate")
        UserDefaults.shared.removeObject(forKey: "refreshFrequency")
        UserDefaults.shared.removeObject(forKey: "decimalPlaces")
        UserDefaults.shared.removeObject(forKey: "showSunnyBackground")
        UserDefaults.shared.removeObject(forKey: "showUsableBatteryOnly")
        UserDefaults.shared.removeObject(forKey: "showTotalYield")
        UserDefaults.shared.removeObject(forKey: "devices")
        UserDefaults.shared.removeObject(forKey: "selectedDeviceID")
        UserDefaults.shared.removeObject(forKey: "displayUnit")
        UserDefaults.shared.removeObject(forKey: "showInverterTemperature")
        UserDefaults.shared.removeObject(forKey: "showHomeTotalOnPowerFlow")
        UserDefaults.shared.removeObject(forKey: "showInverterIcon")
        UserDefaults.shared.removeObject(forKey: "shouldInvertCT2")
        UserDefaults.shared.removeObject(forKey: "showInverterPlantName")
        UserDefaults.shared.removeObject(forKey: "showGridTotalsOnPowerFlow")
        UserDefaults.shared.removeObject(forKey: "showInverterTypeNameOnPowerFlow")
        UserDefaults.shared.removeObject(forKey: "showLastUpdateTimestamp")
        UserDefaults.shared.removeObject(forKey: "selfSufficiencyEstimateMode")
        UserDefaults.shared.removeObject(forKey: "showFinancialEarnings")
        UserDefaults.shared.removeObject(forKey: "financialModel")
        UserDefaults.shared.removeObject(forKey: "feedInUnitPrice")
        UserDefaults.shared.removeObject(forKey: "gridImportUnitPrice")
        UserDefaults.shared.removeObject(forKey: "currencySymbol")
        UserDefaults.shared.removeObject(forKey: "shouldCombineCT2WithPVPower")
        UserDefaults.shared.removeObject(forKey: "selectedParameterGraphVariables")
        UserDefaults.shared.removeObject(forKey: "deviceBatteryOverrides")
        UserDefaults.shared.removeObject(forKey: "solarDefinitions")
        UserDefaults.shared.removeObject(forKey: "parameterGroups")
    }

    private func bool(from source: UserDefaults, forKey key: String, defaultValue: Bool) -> Bool {
        (source.object(forKey: key) as? Bool) ?? defaultValue
    }

    private func integer(from source: UserDefaults, forKey key: String, defaultValue: Int) -> Int {
        (source.object(forKey: key) as? Int) ?? defaultValue
    }

    @UserDefaultsStoredBool(key: "showGraphValueDescriptions", defaultValue: true)
    public var showGraphValueDescriptions: Bool

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

    @UserDefaultsStoredOptionalString(key: "selectedDeviceID")
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
    public var showFinancialEarnings: Bool

    @UserDefaultsStoredInt(key: "financialModel", defaultValue: 1)
    public var financialModel: Int

    @UserDefaultsStoredDouble(key: "feedInUnitPrice", defaultValue: 0.05)
    public var feedInUnitPrice: Double

    @UserDefaultsStoredDouble(key: "gridImportUnitPrice", defaultValue: 0.15)
    public var gridImportUnitPrice: Double

    @UserDefaultsStoredString(key: "currencySymbol", defaultValue: "£")
    public var currencySymbol: String

    @UserDefaultsStoredBool(key: "shouldCombineCT2WithPVPower", defaultValue: true)
    public var shouldCombineCT2WithPVPower: Bool

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
public struct UserDefaultsStoredDouble {
    var key: String
    var defaultValue: Double = 0.0

    public var wrappedValue: Double {
        get {
            (UserDefaults.shared.object(forKey: key) as? Double) ?? defaultValue
        }
        set {
            UserDefaults.shared.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultsStoredOptionalString {
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
public struct UserDefaultsStoredString {
    var key: String
    var defaultValue: String

    public var wrappedValue: String {
        get {
            UserDefaults.shared.string(forKey: key) ?? defaultValue
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
