//
//  AppSettingsPublisherFactory.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 02/12/2023.
//

import Combine
import Foundation

public enum AppSettingsPublisherFactory {
    public static func make(from config: Config) -> CurrentValueSubject<AppSettings, Never> {
        CurrentValueSubject(
            AppSettings(
                showColouredLines: config.showColouredLines,
                showBatteryTemperature: config.showBatteryTemperature,
                showSunnyBackground: config.showSunnyBackground,
                decimalPlaces: config.decimalPlaces,
                showBatteryEstimate: config.showBatteryEstimate,
                showUsableBatteryOnly: config.showUsableBatteryOnly,
                displayUnit: DisplayUnit(rawValue: config.displayUnit) ?? .kilowatt,
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
                shouldCombineCT2WithLoadsPower: config.shouldCombineCT2WithLoadsPower,
                showGraphValueDescriptions: config.showGraphValueDescriptions,
                solcastSettings: config.solcastSettings,
                dataCeiling: config.dataCeiling,
                showTotalYieldOnPowerFlow: config.showTotalYieldOnPowerFlow,
                showFinancialSummaryOnFlowPage: config.showFinancialSummaryOnFlowPage,
                separateParameterGraphsByUnit: config.separateParameterGraphsByUnit,
                currencySymbol: config.currencySymbol,
                showInverterTypeName: config.showInverterTypeName,
                showSeparateStringsOnFlowPage: config.showSeparateStringsOnFlowPage,
                showBatteryPercentageRemaining: config.showBatteryPercentageRemaining
            )
        )
    }
}
