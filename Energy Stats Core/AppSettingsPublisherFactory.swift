//
//  AppSettingsPublisherFactory.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 02/12/2023.
//

import Combine
import Foundation

public typealias CurrentAppSettings = CurrentValueSubject<AppSettings, Never>

public enum AppSettingsPublisherFactory {
    public static var shared: CurrentAppSettings?

    public static func make() -> CurrentAppSettings {
        if let shared = AppSettingsPublisherFactory.shared {
            return shared
        } else {
            let value: CurrentAppSettings = CurrentValueSubject(AppSettings.mock())
            AppSettingsPublisherFactory.shared = value
            return value
        }
    }

    public static func update(from config: ConfigManaging) {
        AppSettingsPublisherFactory.shared?.value = AppSettings(
            showColouredLines: config.showColouredLines,
            showBatteryTemperature: config.showBatteryTemperature,
            showSunnyBackground: config.showSunnyBackground,
            decimalPlaces: config.decimalPlaces,
            showBatteryEstimate: config.showBatteryEstimate,
            showUsableBatteryOnly: config.showUsableBatteryOnly,
            displayUnit: config.displayUnit,
            selfSufficiencyEstimateMode: config.selfSufficiencyEstimateMode,
            showFinancialEarnings: config.showFinancialEarnings,
            feedInUnitPrice: config.feedInUnitPrice,
            gridImportUnitPrice: config.gridImportUnitPrice,
            showInverterTemperature: config.showInverterTemperature,
            showHomeTotalOnPowerFlow: config.showHomeTotalOnPowerFlow,
            showInverterIcon: config.showInverterIcon,
            shouldInvertCT2: config.shouldInvertCT2,
            showInverterStationName: config.showInverterStationName,
            showGridTotalsOnPowerFlow: config.showGridTotalsOnPowerFlow,
            showLastUpdateTimestamp: config.showLastUpdateTimestamp,
            solarDefinitions: config.solarDefinitions,
            parameterGroups: config.parameterGroups,
            shouldCombineCT2WithPVPower: config.shouldCombineCT2WithPVPower,
            showGraphValueDescriptions: config.showGraphValueDescriptions,
            solcastSettings: config.solcastSettings,
            dataCeiling: config.dataCeiling,
            showTotalYieldOnPowerFlow: config.showTotalYieldOnPowerFlow,
            showFinancialSummaryOnFlowPage: config.showFinancialSummaryOnFlowPage,
            separateParameterGraphsByUnit: config.separateParameterGraphsByUnit,
            currencySymbol: config.currencySymbol,
            showInverterTypeName: config.showInverterTypeName,
            powerFlowStrings: config.powerFlowStrings,
            showBatteryPercentageRemaining: config.showBatteryPercentageRemaining,
            showSelfSufficiencyStatsGraphOverlay: config.showSelfSufficiencyStatsGraphOverlay,
            truncatedYAxisOnParameterGraphs: config.truncatedYAxisOnParameterGraphs,
            earningsModel: config.earningsModel,
            minSOC: config.minSOC,
            batteryTemperatureDisplayMode: config.batteryTemperatureDisplayMode,
            showInverterScheduleQuickLink: config.showInverterScheduleQuickLink,
            fetchSolcastOnAppLaunch: config.fetchSolcastOnAppLaunch,
            ct2DisplayMode: config.ct2DisplayMode,
            shouldCombineCT2WithLoadsPower: config.shouldCombineCT2WithLoadsPower
        )
    }
}
