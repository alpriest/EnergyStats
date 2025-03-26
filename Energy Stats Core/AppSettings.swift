//
//  AppSettings.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/04/2023.
//

import Combine
import Foundation

public enum SelfSufficiencyEstimateMode: Int, RawRepresentable {
    case off = 0
    case net = 1
    case absolute = 2
}

public struct AppSettings {
    public var showColouredLines: Bool
    public var showBatteryTemperature: Bool
    public var showSunnyBackground: Bool
    public var decimalPlaces: Int
    public var showBatteryEstimate: Bool
    public var showUsableBatteryOnly: Bool
    public var displayUnit: DisplayUnit
    public var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode
    public var showFinancialEarnings: Bool
    public var feedInUnitPrice: Double
    public var gridImportUnitPrice: Double
    public var showInverterTemperature: Bool
    public var showHomeTotalOnPowerFlow: Bool
    public var showInverterIcon: Bool
    public var shouldInvertCT2: Bool
    public var showInverterStationName: Bool
    public var showGridTotalsOnPowerFlow: Bool
    public var showLastUpdateTimestamp: Bool
    public var solarDefinitions: SolarRangeDefinitions
    public var parameterGroups: [ParameterGroup]
    public var shouldCombineCT2WithPVPower: Bool
    public var showGraphValueDescriptions: Bool
    public var solcastSettings: SolcastSettings
    public var dataCeiling: DataCeiling
    public var showTotalYieldOnPowerFlow: Bool
    public var showFinancialSummaryOnFlowPage: Bool
    public var separateParameterGraphsByUnit: Bool
    public var currencySymbol: String
    public var showInverterTypeName: Bool
    public var powerFlowStrings: PowerFlowStringsSettings
    public var showBatteryPercentageRemaining: Bool
    public var showSelfSufficiencyStatsGraphOverlay: Bool
    public var truncatedYAxisOnParameterGraphs: Bool
    public var earningsModel: EarningsModel
    public var minSOC: Double
    public var batteryTemperatureDisplayMode: BatteryTemperatureDisplayMode
    public var showInverterScheduleQuickLink: Bool
    public var fetchSolcastOnAppLaunch: Bool
    public var ct2DisplayMode: CT2DisplayMode
    public var shouldCombineCT2WithLoadsPower: Bool

    public init(
        showColouredLines: Bool,
        showBatteryTemperature: Bool,
        showSunnyBackground: Bool,
        decimalPlaces: Int,
        showBatteryEstimate: Bool,
        showUsableBatteryOnly: Bool,
        displayUnit: DisplayUnit,
        selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode,
        showFinancialEarnings: Bool,
        feedInUnitPrice: Double,
        gridImportUnitPrice: Double,
        showInverterTemperature: Bool,
        showHomeTotalOnPowerFlow: Bool,
        showInverterIcon: Bool,
        shouldInvertCT2: Bool,
        showInverterStationName: Bool,
        showGridTotalsOnPowerFlow: Bool,
        showLastUpdateTimestamp: Bool,
        solarDefinitions: SolarRangeDefinitions,
        parameterGroups: [ParameterGroup],
        shouldCombineCT2WithPVPower: Bool,
        showGraphValueDescriptions: Bool,
        solcastSettings: SolcastSettings,
        dataCeiling: DataCeiling,
        showTotalYieldOnPowerFlow: Bool,
        showFinancialSummaryOnFlowPage: Bool,
        separateParameterGraphsByUnit: Bool,
        currencySymbol: String,
        showInverterTypeName: Bool,
        powerFlowStrings: PowerFlowStringsSettings,
        showBatteryPercentageRemaining: Bool,
        showSelfSufficiencyStatsGraphOverlay: Bool,
        truncatedYAxisOnParameterGraphs: Bool,
        earningsModel: EarningsModel,
        minSOC: Double,
        batteryTemperatureDisplayMode: BatteryTemperatureDisplayMode,
        showInverterScheduleQuickLink: Bool,
        fetchSolcastOnAppLaunch: Bool,
        ct2DisplayMode: CT2DisplayMode,
        shouldCombineCT2WithLoadsPower: Bool
    ) {
        self.showColouredLines = showColouredLines
        self.showBatteryTemperature = showBatteryTemperature
        self.showSunnyBackground = showSunnyBackground
        self.decimalPlaces = decimalPlaces
        self.showBatteryEstimate = showBatteryEstimate
        self.showUsableBatteryOnly = showUsableBatteryOnly
        self.displayUnit = displayUnit
        self.showTotalYieldOnPowerFlow = showTotalYieldOnPowerFlow
        self.selfSufficiencyEstimateMode = selfSufficiencyEstimateMode
        self.showFinancialEarnings = showFinancialEarnings
        self.feedInUnitPrice = feedInUnitPrice
        self.gridImportUnitPrice = gridImportUnitPrice
        self.showInverterTemperature = showInverterTemperature
        self.showHomeTotalOnPowerFlow = showHomeTotalOnPowerFlow
        self.showInverterIcon = showInverterIcon
        self.shouldInvertCT2 = shouldInvertCT2
        self.showInverterStationName = showInverterStationName
        self.showGridTotalsOnPowerFlow = showGridTotalsOnPowerFlow
        self.showLastUpdateTimestamp = showLastUpdateTimestamp
        self.solarDefinitions = solarDefinitions
        self.parameterGroups = parameterGroups
        self.shouldCombineCT2WithPVPower = shouldCombineCT2WithPVPower
        self.showGraphValueDescriptions = showGraphValueDescriptions
        self.solcastSettings = solcastSettings
        self.dataCeiling = dataCeiling
        self.showFinancialSummaryOnFlowPage = showFinancialSummaryOnFlowPage
        self.separateParameterGraphsByUnit = separateParameterGraphsByUnit
        self.currencySymbol = currencySymbol
        self.showInverterTypeName = showInverterTypeName
        self.powerFlowStrings = powerFlowStrings
        self.showBatteryPercentageRemaining = showBatteryPercentageRemaining
        self.showSelfSufficiencyStatsGraphOverlay = showSelfSufficiencyStatsGraphOverlay
        self.truncatedYAxisOnParameterGraphs = truncatedYAxisOnParameterGraphs
        self.earningsModel = earningsModel
        self.minSOC = minSOC
        self.batteryTemperatureDisplayMode = batteryTemperatureDisplayMode
        self.showInverterScheduleQuickLink = showInverterScheduleQuickLink
        self.fetchSolcastOnAppLaunch = fetchSolcastOnAppLaunch
        self.ct2DisplayMode = ct2DisplayMode
        self.shouldCombineCT2WithLoadsPower = shouldCombineCT2WithLoadsPower
    }

    public func copy(
        showColouredLines: Bool? = nil,
        showBatteryTemperature: Bool? = nil,
        showSunnyBackground: Bool? = nil,
        decimalPlaces: Int? = nil,
        showBatteryEstimate: Bool? = nil,
        showUsableBatteryOnly: Bool? = nil,
        displayUnit: DisplayUnit? = nil,
        selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode? = nil,
        showFinancialEarnings: Bool? = nil,
        feedInUnitPrice: Double? = nil,
        gridImportUnitPrice: Double? = nil,
        showInverterTemperature: Bool? = nil,
        showHomeTotalOnPowerFlow: Bool? = nil,
        showInverterIcon: Bool? = nil,
        shouldInvertCT2: Bool? = nil,
        showInverterStationName: Bool? = nil,
        showGridTotalsOnPowerFlow: Bool? = nil,
        showLastUpdateTimestamp: Bool? = nil,
        solarDefinitions: SolarRangeDefinitions? = nil,
        parameterGroups: [ParameterGroup]? = nil,
        shouldCombineCT2WithPVPower: Bool? = nil,
        showGraphValueDescriptions: Bool? = nil,
        solcastSettings: SolcastSettings? = nil,
        dataCeiling: DataCeiling? = nil,
        showTotalYieldOnPowerFlow: Bool? = nil,
        showFinancialSummaryOnFlowPage: Bool? = nil,
        separateParameterGraphsByUnit: Bool? = nil,
        currencySymbol: String? = nil,
        showInverterTypeName: Bool? = nil,
        powerFlowStrings: PowerFlowStringsSettings? = nil,
        showBatteryPercentageRemaining: Bool? = nil,
        showSelfSufficiencyStatsGraphOverlay: Bool? = nil,
        truncatedYAxisOnParameterGraphs: Bool? = nil,
        earningsModel: EarningsModel? = nil,
        minSOC: Double? = nil,
        batteryTemperatureDisplayMode: BatteryTemperatureDisplayMode? = nil,
        showInverterScheduleQuickLink: Bool? = nil,
        fetchSolcastOnAppLaunch: Bool? = nil,
        ct2DisplayMode: CT2DisplayMode? = nil,
        shouldCombineCT2WithLoadsPower: Bool? = nil
    ) -> AppSettings {
        AppSettings(
            showColouredLines: showColouredLines ?? self.showColouredLines,
            showBatteryTemperature: showBatteryTemperature ?? self.showBatteryTemperature,
            showSunnyBackground: showSunnyBackground ?? self.showSunnyBackground,
            decimalPlaces: decimalPlaces ?? self.decimalPlaces,
            showBatteryEstimate: showBatteryEstimate ?? self.showBatteryEstimate,
            showUsableBatteryOnly: showUsableBatteryOnly ?? self.showUsableBatteryOnly,
            displayUnit: displayUnit ?? self.displayUnit,
            selfSufficiencyEstimateMode: selfSufficiencyEstimateMode ?? self.selfSufficiencyEstimateMode,
            showFinancialEarnings: showFinancialEarnings ?? self.showFinancialEarnings,
            feedInUnitPrice: feedInUnitPrice ?? self.feedInUnitPrice,
            gridImportUnitPrice: gridImportUnitPrice ?? self.gridImportUnitPrice,
            showInverterTemperature: showInverterTemperature ?? self.showInverterTemperature,
            showHomeTotalOnPowerFlow: showHomeTotalOnPowerFlow ?? self.showHomeTotalOnPowerFlow,
            showInverterIcon: showInverterIcon ?? self.showInverterIcon,
            shouldInvertCT2: shouldInvertCT2 ?? self.shouldInvertCT2,
            showInverterStationName: showInverterStationName ?? self.showInverterStationName,
            showGridTotalsOnPowerFlow: showGridTotalsOnPowerFlow ?? self.showGridTotalsOnPowerFlow,
            showLastUpdateTimestamp: showLastUpdateTimestamp ?? self.showLastUpdateTimestamp,
            solarDefinitions: solarDefinitions ?? self.solarDefinitions,
            parameterGroups: parameterGroups ?? self.parameterGroups,
            shouldCombineCT2WithPVPower: shouldCombineCT2WithPVPower ?? self.shouldCombineCT2WithPVPower,
            showGraphValueDescriptions: showGraphValueDescriptions ?? self.showGraphValueDescriptions,
            solcastSettings: solcastSettings ?? self.solcastSettings,
            dataCeiling: dataCeiling ?? self.dataCeiling,
            showTotalYieldOnPowerFlow: showTotalYieldOnPowerFlow ?? self.showTotalYieldOnPowerFlow,
            showFinancialSummaryOnFlowPage: showFinancialSummaryOnFlowPage ?? self.showFinancialSummaryOnFlowPage,
            separateParameterGraphsByUnit: separateParameterGraphsByUnit ?? self.separateParameterGraphsByUnit,
            currencySymbol: currencySymbol ?? self.currencySymbol,
            showInverterTypeName: showInverterTypeName ?? self.showInverterTypeName,
            powerFlowStrings: powerFlowStrings ?? self.powerFlowStrings,
            showBatteryPercentageRemaining: showBatteryPercentageRemaining ?? self.showBatteryPercentageRemaining,
            showSelfSufficiencyStatsGraphOverlay: showSelfSufficiencyStatsGraphOverlay ?? self.showSelfSufficiencyStatsGraphOverlay,
            truncatedYAxisOnParameterGraphs: truncatedYAxisOnParameterGraphs ?? self.truncatedYAxisOnParameterGraphs,
            earningsModel: earningsModel ?? self.earningsModel,
            minSOC: minSOC ?? self.minSOC,
            batteryTemperatureDisplayMode: batteryTemperatureDisplayMode ?? self.batteryTemperatureDisplayMode,
            showInverterScheduleQuickLink: showInverterScheduleQuickLink ?? self.showInverterScheduleQuickLink,
            fetchSolcastOnAppLaunch: fetchSolcastOnAppLaunch ?? self.fetchSolcastOnAppLaunch,
            ct2DisplayMode: ct2DisplayMode ?? self.ct2DisplayMode,
            shouldCombineCT2WithLoadsPower: shouldCombineCT2WithLoadsPower ?? self.shouldCombineCT2WithLoadsPower
        )
    }
}

public typealias LatestAppSettingsPublisher = CurrentValueSubject<AppSettings, Never>
