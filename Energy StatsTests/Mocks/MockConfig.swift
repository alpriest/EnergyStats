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

    var currencySymbol: String = ""
    var shouldCombineCT2WithPVPower: Bool = true
    var showGraphValueDescriptions: Bool = true
    var solcastResourceId: String?
    var solcastApiKey: String?
    var hasRunBefore: Bool = true
    var displayUnit: Int = 0
    var showFinancialEarnings: Bool = true
    var selectedParameterGraphVariables: [String] = []
    var showHomeTotalOnPowerFlow: Bool = false
    var showInverterIcon: Bool = false
    var shouldInvertCT2: Bool = false
    var showInverterStationName: Bool = false
    var showGridTotalsOnPowerFlow: Bool = false
    var deviceBatteryOverrides: [String: String] = [:]
    var showLastUpdateTimestamp: Bool = false
    var solarDefinitions: SolarRangeDefinitions = .default()
    var parameterGroups: [ParameterGroup] = []
    var feedInUnitPrice: Double = 0.0
    var gridImportUnitPrice: Double = 0.0
    var showTotalYield: Bool = false
    var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode = .absolute
    var showEarnings: Bool = false
    var showInW: Bool = false
    var isDemoUser: Bool = false
    var showColouredLines: Bool = true
    var showBatteryTemperature: Bool = true
    var refreshFrequency: Int = 0
    var decimalPlaces: Int = 2
    var showSunnyBackground: Bool = true
    var showUsableBatteryOnly: Bool = false
    var showBatteryEstimate: Bool = false
    var devices: Data? = nil
    var showInverterTemperature: Bool = false
    var selectedDeviceSN: String? = "DEVICESN"
    var solcastSettings: SolcastSettings = .init(apiKey: nil, sites: [])
    var dataCeiling: DataCeiling = .none
    var showTotalYieldOnPowerFlow: Bool = false
    var showFinancialSummaryOnFlowPage: Bool = false
    var separateParameterGraphsByUnit: Bool = false
    var variables: [Variable] = []
    var powerFlowStrings: PowerFlowStringsSettings = .none
    var showBatteryPercentageRemaining: Bool = false
    var showInverterTypeName: Bool = false
    var powerStationDetail: PowerStationDetail? = nil
    var showSelfSufficiencyStatsGraphOverlay: Bool = false
    var scheduleTemplates: [ScheduleTemplate] = []
    var truncatedYAxisOnParameterGraphs: Bool = false
    var earningsModel: EarningsModel = .exported
    var summaryDateRange: SummaryDateRange = .automatic
    var colorScheme: ForcedColorScheme = .auto
    var lastSolcastRefresh: Date? = nil
    var batteryTemperatureDisplayMode: BatteryTemperatureDisplayMode = .automatic
    var fetchSolcastOnAppLaunch: Bool = false
    var showInverterScheduleQuickLink: Bool = true
}
