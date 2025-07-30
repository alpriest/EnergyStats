//
//  MockConfig.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

@testable import Energy_Stats
import Energy_Stats_Core
import Foundation

class MockConfig: Config {
    func clearDisplaySettings() {}
    func clearDeviceSettings() {}

    var batteryTemperatureDisplayMode: BatteryTemperatureDisplayMode = .automatic
    var colorScheme: ForcedColorScheme = .auto
    var currencySymbol: String = ""
    var ct2DisplayMode: CT2DisplayMode = .hidden
    var dataCeiling: DataCeiling = .none
    var decimalPlaces: Int = 2
    var devices: Data? = nil
    var earningsModel: EarningsModel = .exported
    var fetchSolcastOnAppLaunch: Bool = false
    var feedInUnitPrice: Double = 0.0
    var shouldCombineCT2WithLoadsPower: Bool = false
    var shouldCombineCT2WithPVPower: Bool = true
    var showBatteryEstimate: Bool = false
    var showBatteryPercentageRemaining: Bool = false
    var showBatteryTemperature: Bool = true
    var showColouredLines: Bool = true
    var showEarnings: Bool = false
    var showFinancialEarnings: Bool = true
    var showFinancialSummaryOnFlowPage: Bool = false
    var showGraphValueDescriptions: Bool = true
    var showGridTotalsOnPowerFlow: Bool = false
    var showHomeTotalOnPowerFlow: Bool = false
    var showInW: Bool = false
    var showInverterIcon: Bool = false
    var showInverterScheduleQuickLink: Bool = true
    var showInverterStationName: Bool = false
    var showInverterTemperature: Bool = false
    var showInverterTypeName: Bool = false
    var showLastUpdateTimestamp: Bool = false
    var showSelfSufficiencyStatsGraphOverlay: Bool = false
    var showSunnyBackground: Bool = true
    var showTotalYield: Bool = false
    var showTotalYieldOnPowerFlow: Bool = false
    var showUsableBatteryOnly: Bool = false
    var shouldInvertCT2: Bool = false
    var separateParameterGraphsByUnit: Bool = false
    var selectedDeviceSN: String? = "DEVICESN"
    var selectedParameterGraphVariables: [String] = []
    var scheduleTemplates: [ScheduleTemplate] = []
    var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode = .absolute
    var solcastApiKey: String?
    var solcastResourceId: String?
    var solcastSettings: SolcastSettings = .init(apiKey: nil, sites: [])
    var summaryDateRange: SummaryDateRange = .automatic
    var truncatedYAxisOnParameterGraphs: Bool = false
    var variables: [Variable] = []
    var powerFlowStrings: PowerFlowStringsSettings = .none
    var powerStationDetail: PowerStationDetail? = nil
    var parameterGroups: [ParameterGroup] = []
    var deviceBatteryOverrides: [String: String] = [:]
    var lastSolcastRefresh: Date? = nil
    var hasRunBefore: Bool = true
    var isDemoUser: Bool = false
    var seenTips: [TipType] = []
    var refreshFrequency: Int = 60
    var displayUnit: Int = 0
    var solarDefinitions: SolarRangeDefinitions = SolarRangeDefinitions.default
    var gridImportUnitPrice: Double = 0.0
    var showInverterConsumption: Bool = false
    var showBatterySOCOnDailyStats: Bool = false
}
