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

public class UserDefaultsConfig: StoredConfig {
    public init() {}
    
    public func clearDisplaySettings() {
        UserDefaults.shared.removeObject(forKey: "showGraphValueDescriptions")
        UserDefaults.shared.removeObject(forKey: "hasRunBefore")
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
        UserDefaults.shared.removeObject(forKey: "selectedParameterGraphVariables")
        UserDefaults.shared.removeObject(forKey: "solarDefinitions")
        UserDefaults.shared.removeObject(forKey: "parameterGroups")
        UserDefaults.shared.removeObject(forKey: "dataCeiling")
        UserDefaults.shared.removeObject(forKey: "showTotalYieldOnPowerFlow")
        UserDefaults.shared.removeObject(forKey: "showFinancialSummaryOnFlowPage")
        UserDefaults.shared.removeObject(forKey: "separateParameterGraphsByUnit")
        UserDefaults.shared.removeObject(forKey: "showInverterTypeName")
        UserDefaults.shared.removeObject(forKey: "powerFlowStringsSettings")
        UserDefaults.shared.removeObject(forKey: "showBatteryPercentageRemaining")
        UserDefaults.shared.removeObject(forKey: "showSelfSufficiencyStatsGraphOverlay")
        UserDefaults.shared.removeObject(forKey: "truncatedYAxisOnParameterGraphs")
        UserDefaults.shared.removeObject(forKey: "earningsModel")
        UserDefaults.shared.removeObject(forKey: "summaryDateRange")
        UserDefaults.shared.removeObject(forKey: "colorScheme")
        UserDefaults.shared.removeObject(forKey: "lastSolcastRefresh")
        UserDefaults.shared.removeObject(forKey: "batteryTemperatureDisplayMode")
        UserDefaults.shared.removeObject(forKey: "showInverterScheduleQuickLink")
        UserDefaults.shared.removeObject(forKey: "fetchSolcastOnAppLaunch")
        UserDefaults.shared.removeObject(forKey: "ct2DisplayMode")
        UserDefaults.shared.removeObject(forKey: "seenTips")
        UserDefaults.shared.removeObject(forKey: "shouldCombineCT2WithLoadsPower")
        UserDefaults.shared.removeObject(forKey: "showInverterConsumption")
        UserDefaults.shared.removeObject(forKey: "showBatterySOCOnDailyStats")
        UserDefaults.shared.removeObject(forKey: "allowNegativeLoad")
        UserDefaults.shared.removeObject(forKey: "workModes")
        UserDefaults.shared.removeObject(forKey: "showOutputEnergyOnStats")
        UserDefaults.shared.removeObject(forKey: "isReadOnly")
        UserDefaults.shared.removeObject(forKey: "readOnlyCode")
        UserDefaults.shared.synchronize()
    }
    
    public func clearDeviceSettings() {
        UserDefaults.shared.removeObject(forKey: "isDemoUser")
        UserDefaults.shared.removeObject(forKey: "devices")
        UserDefaults.shared.removeObject(forKey: "selectedDeviceSN")
        UserDefaults.shared.removeObject(forKey: "powerStationDetail")
        UserDefaults.shared.removeObject(forKey: "deviceBatteryOverrides")
        UserDefaults.shared.removeObject(forKey: "solcastSettings")
        UserDefaults.shared.removeObject(forKey: "pvOutputConfig")
        UserDefaults.shared.synchronize()
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
    
    @UserDefaultsStoredBool(key: "showHomeTotalOnPowerFlow", defaultValue: false)
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
            guard let solarDefinitions = UserDefaults.shared.data(forKey: "solarDefinitions") else { return .default }
            do {
                return try JSONDecoder().decode(SolarRangeDefinitions.self, from: solarDefinitions)
            } catch {
                return .default
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
    
    @UserDefaultsStoredBool(key: "useTraditionalLoadFormula", defaultValue: true)
    public var useTraditionalLoadFormula: Bool
    
    @UserDefaultsStoredCodable(key: "powerFlowStringsSettings", defaultValue: PowerFlowStringsSettings.none)
    public var powerFlowStrings: PowerFlowStringsSettings
    
    @UserDefaultsStoredBool(key: "showBatteryPercentageRemaining", defaultValue: true)
    public var showBatteryPercentageRemaining: Bool
    
    @UserDefaultsStoredCodable(key: "powerStationDetail", defaultValue: nil)
    public var powerStationDetail: PowerStationDetail?
    
    @UserDefaultsStoredBool(key: "showSelfSufficiencyStatsGraphOverlay", defaultValue: true)
    public var showSelfSufficiencyStatsGraphOverlay: Bool
    
    public var scheduleTemplates: [ScheduleTemplate] {
        get {
            guard let data = UserDefaults.shared.data(forKey: "scheduleTemplates") else { return [] }
            let templates = (try? JSONDecoder().decode([ScheduleTemplate].self, from: data)) ?? []
            return templates
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.shared.set(data, forKey: "scheduleTemplates")
        }
    }
    
    @UserDefaultsStoredBool(key: "truncatedYAxisOnParameterGraphs", defaultValue: false)
    public var truncatedYAxisOnParameterGraphs: Bool
    
    public var earningsModel: EarningsModel {
        get {
            let rawValue = UserDefaults.shared.integer(forKey: "earningsModel")
            return EarningsModel(rawValue: rawValue) ?? .exported
        }
        set {
            UserDefaults.shared.set(newValue.rawValue, forKey: "earningsModel")
        }
    }
    
    @UserDefaultsStoredCodable(key: "summaryDateRange", defaultValue: SummaryDateRange.automatic)
    public var summaryDateRange: SummaryDateRange
    
    @UserDefaultsStoredCodable(key: "colorScheme", defaultValue: ForcedColorScheme.auto)
    public var colorScheme: ForcedColorScheme
    
    public var lastSolcastRefresh: Date? {
        get {
            UserDefaults.shared.object(forKey: "lastSolcastRefresh") as? Date
        }
        set {
            UserDefaults.shared.set(newValue, forKey: "lastSolcastRefresh")
        }
    }
    
    @UserDefaultsStoredCodable(key: "batteryTemperatureDisplayMode", defaultValue: BatteryTemperatureDisplayMode.automatic)
    public var batteryTemperatureDisplayMode: BatteryTemperatureDisplayMode
    
    @UserDefaultsStoredBool(key: "showInverterScheduleQuickLink")
    public var showInverterScheduleQuickLink: Bool
    
    @UserDefaultsStoredBool(key: "fetchSolcastOnAppLaunch")
    public var fetchSolcastOnAppLaunch: Bool
    
    public var ct2DisplayMode: CT2DisplayMode {
        get {
            let rawValue = UserDefaults.shared.integer(forKey: "ct2DisplayMode")
            return CT2DisplayMode(rawValue: rawValue) ?? .hidden
        }
        set {
            UserDefaults.shared.set(newValue.rawValue, forKey: "ct2DisplayMode")
        }
    }
    
    @UserDefaultsStoredCodable(key: "seenTips", defaultValue: [])
    public var seenTips: [TipType]
    
    @UserDefaultsStoredBool(key: "shouldCombineCT2WithLoadsPower", defaultValue: true)
    public var shouldCombineCT2WithLoadsPower: Bool
    
    @UserDefaultsStoredBool(key: "showInverterConsumption", defaultValue: false)
    public var showInverterConsumption: Bool
    
    @UserDefaultsStoredBool(key: "showBatterySOCOnDailyStats", defaultValue: false)
    public var showBatterySOCOnDailyStats: Bool
    
    @UserDefaultsStoredBool(key: "allowNegativeLoad", defaultValue: false)
    public var allowNegativeLoad: Bool
    
    @UserDefaultsStoredCodable(key: "workModes", defaultValue: [])
    public var workModes: [WorkMode]
    
    @UserDefaultsStoredBool(key: "showOutputEnergyOnStats", defaultValue: false)
    public var showOutputEnergyOnStats: Bool
    
    @UserDefaultsStoredCodable(key: "pvOutputConfig", defaultValue: nil)
    public var pvOutputConfig: PVOutputConfig?
    
    @UserDefaultsStoredBool(key: "isReadOnly", defaultValue: false)
    public var isReadOnly: Bool
    
    @UserDefaultsStoredString(key: "readOnlyCode", defaultValue: "")
    public var readOnlyCode: String
 }
