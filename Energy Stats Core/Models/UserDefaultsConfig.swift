//
//  UserDefaultsConfig.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 20/11/2023.
//

import Foundation

public extension UserDefaults {
    static var shared: UserDefaults {
        UserDefaults(suiteName: "group.com.alpriest.EnergyStats")!
    }
}

public class UserDefaultsConfig: Config {
    public init() {}

    public func clearDisplaySettings() {
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
        UserDefaults.shared.removeObject(forKey: "displayUnit")
        UserDefaults.shared.removeObject(forKey: "showInverterTemperature")
        UserDefaults.shared.removeObject(forKey: "showHomeTotalOnPowerFlow")
        UserDefaults.shared.removeObject(forKey: "showInverterIcon")
        UserDefaults.shared.removeObject(forKey: "shouldInvertCT2")
        UserDefaults.shared.removeObject(forKey: "showInverterStationName")
        UserDefaults.shared.removeObject(forKey: "showGridTotalsOnPowerFlow")
        UserDefaults.shared.removeObject(forKey: "showLastUpdateTimestamp")
        UserDefaults.shared.removeObject(forKey: "selfSufficiencyEstimateMode")
        UserDefaults.shared.removeObject(forKey: "showFinancialEarnings")
        UserDefaults.shared.removeObject(forKey: "feedInUnitPrice")
        UserDefaults.shared.removeObject(forKey: "gridImportUnitPrice")
        UserDefaults.shared.removeObject(forKey: "currencySymbol")
        UserDefaults.shared.removeObject(forKey: "shouldCombineCT2WithPVPower")
        UserDefaults.shared.removeObject(forKey: "shouldCombineCT2WithLoadsPower")
        UserDefaults.shared.removeObject(forKey: "selectedParameterGraphVariables")
        UserDefaults.shared.removeObject(forKey: "deviceBatteryOverrides")
        UserDefaults.shared.removeObject(forKey: "solarDefinitions")
        UserDefaults.shared.removeObject(forKey: "parameterGroups")
        UserDefaults.shared.removeObject(forKey: "solcastSettings")
        UserDefaults.shared.removeObject(forKey: "dataCeiling")
        UserDefaults.shared.removeObject(forKey: "showTotalYieldOnPowerFlow")
        UserDefaults.shared.removeObject(forKey: "showFinancialSummaryOnFlowPage")
        UserDefaults.shared.removeObject(forKey: "separateParameterGraphsByUnit")
        UserDefaults.shared.removeObject(forKey: "showInverterTypeName")
        UserDefaults.shared.removeObject(forKey: "showSeparateStringsOnFlowPage")
        UserDefaults.shared.removeObject(forKey: "useExperimentalLoadFormula")
    }

    public func clearDeviceSettings() {
        UserDefaults.shared.removeObject(forKey: "devices")
        UserDefaults.shared.removeObject(forKey: "selectedDeviceID")
        UserDefaults.shared.removeObject(forKey: "selectedDeviceSN")
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

    @UserDefaultsStoredBool(key: "showTotalYieldOnPowerFlow", defaultValue: false)
    public var showTotalYieldOnPowerFlow: Bool

    @UserDefaultsStoredData(key: "devices")
    public var devices: Data?

    @UserDefaultsStoredOptionalString(key: "selectedDeviceSN")
    public var selectedDeviceSN: String?

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

    @UserDefaultsStoredBool(key: "showInverterStationName", defaultValue: false)
    public var showInverterStationName: Bool

    @UserDefaultsStoredBool(key: "showInverterTypeName", defaultValue: false)
    public var showInverterTypeName: Bool

    @UserDefaultsStoredBool(key: "showGridTotalsOnPowerFlow", defaultValue: false)
    public var showGridTotalsOnPowerFlow: Bool

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

    @UserDefaultsStoredDouble(key: "feedInUnitPrice", defaultValue: 0.05)
    public var feedInUnitPrice: Double

    @UserDefaultsStoredDouble(key: "gridImportUnitPrice", defaultValue: 0.15)
    public var gridImportUnitPrice: Double

    @UserDefaultsStoredString(key: "currencySymbol", defaultValue: "£")
    public var currencySymbol: String

    @UserDefaultsStoredBool(key: "showFinancialSummaryOnFlowPage", defaultValue: true)
    public var showFinancialSummaryOnFlowPage: Bool

    @UserDefaultsStoredBool(key: "shouldCombineCT2WithPVPower", defaultValue: true)
    public var shouldCombineCT2WithPVPower: Bool

    @UserDefaultsStoredBool(key: "shouldCombineCT2WithLoadsPower", defaultValue: false)
    public var shouldCombineCT2WithLoadsPower: Bool

    @UserDefaultsStoredBool(key: "showSeparateStringsOnFlowPage", defaultValue: false)
    public var showSeparateStringsOnFlowPage: Bool

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

    @UserDefaultsStoredCodable(key: "solcastSettings", defaultValue: SolcastSettings(apiKey: nil, sites: []))
    public var solcastSettings: SolcastSettings

    public var dataCeiling: DataCeiling {
        get {
            let rawValue = UserDefaults.shared.integer(forKey: "dataCeiling")
            return DataCeiling(rawValue: rawValue) ?? .mild
        }
        set {
            UserDefaults.shared.set(newValue.rawValue, forKey: "dataCeiling")
        }
    }

    @UserDefaultsStoredBool(key: "separateParameterGraphsByUnit", defaultValue: true)
    public var separateParameterGraphsByUnit: Bool

    @UserDefaultsStoredCodable(key: "variables", defaultValue: [])
    public var variables: [Variable]

    @UserDefaultsStoredBool(key: "useExperimentalLoadFormula", defaultValue: false)
    public var useExperimentalLoadFormula: Bool
}
