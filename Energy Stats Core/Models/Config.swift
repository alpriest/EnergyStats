//
//  Config.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

public protocol Config {
    func clearDisplaySettings()
    func clearDeviceSettings()
    var isDemoUser: Bool { get set }
    var hasRunBefore: Bool { get set }
    var showColouredLines: Bool { get set }
    var showBatteryTemperature: Bool { get set }
    var showBatteryEstimate: Bool { get set }
    var refreshFrequency: Int { get set }
    var decimalPlaces: Int { get set }
    var showSunnyBackground: Bool { get set }
    var devices: Data? { get set }
    var selectedDeviceSN: String? { get set }
    var showUsableBatteryOnly: Bool { get set }
    var displayUnit: Int { get set }
    var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode { get set }
    var showFinancialEarnings: Bool { get set }
    var showInverterTemperature: Bool { get set }
    var selectedParameterGraphVariables: [String] { get set }
    var showHomeTotalOnPowerFlow: Bool { get set }
    var showInverterIcon: Bool { get set }
    var shouldInvertCT2: Bool { get set }
    var showInverterStationName: Bool { get set }
    var showInverterTypeName: Bool { get set }
    var showGridTotalsOnPowerFlow: Bool { get set }
    var deviceBatteryOverrides: [String: String] { get set }
    var showLastUpdateTimestamp: Bool { get set }
    var solarDefinitions: SolarRangeDefinitions { get set }
    var parameterGroups: [ParameterGroup] { get set }
    var feedInUnitPrice: Double { get set }
    var gridImportUnitPrice: Double { get set }
    var currencySymbol: String { get set }
    var shouldCombineCT2WithPVPower: Bool { get set }
    var showGraphValueDescriptions: Bool { get set }
    var solcastSettings: SolcastSettings { get set }
    var dataCeiling: DataCeiling { get set }
    var showTotalYieldOnPowerFlow: Bool { get set }
    var showFinancialSummaryOnFlowPage: Bool { get set }
    var separateParameterGraphsByUnit: Bool { get set }
    var variables: [Variable] { get set }
    var powerFlowStrings: PowerFlowStringsSettings { get set }
    var showBatteryPercentageRemaining: Bool { get set }
    var powerStationDetail: PowerStationDetail? { get set }
    var showSelfSufficiencyStatsGraphOverlay: Bool { get set }
    var scheduleTemplates: [ScheduleTemplate] { get set }
    var truncatedYAxisOnParameterGraphs: Bool { get set }
    var earningsModel: EarningsModel { get set }
    var summaryDateRange: SummaryDateRange { get set }
    var colorScheme: ForcedColorScheme { get set }
    var lastSolcastRefresh: Date? { get set }
    var batteryTemperatureDisplayMode: BatteryTemperatureDisplayMode { get set }
    var showInverterScheduleQuickLink: Bool { get set }
    var showSolcastOnParametersPage: Bool { get set }
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
