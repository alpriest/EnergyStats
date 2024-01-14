//
//  MockAppTheme.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 03/09/2023.
//

import Foundation

public extension AppSettings {
    static func mock(decimalPlaces: Int = 3,
                     displayUnit: DisplayUnit = .kilowatt,
                     showInverterTemperature: Bool = true,
                     selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode = .off,
                     showHomeTotalOnPowerFlow: Bool = true,
                     showInverterStationName: Bool = false) -> AppSettings {
        AppSettings(
            showColouredLines: true,
            showBatteryTemperature: true,
            showSunnyBackground: true,
            decimalPlaces: decimalPlaces,
            showBatteryEstimate: true,
            showUsableBatteryOnly: false,
            displayUnit: displayUnit,
            selfSufficiencyEstimateMode: selfSufficiencyEstimateMode,
            showFinancialEarnings: false,
            feedInUnitPrice: 0.05,
            gridImportUnitPrice: 0.15,
            showInverterTemperature: showInverterTemperature,
            showHomeTotalOnPowerFlow: showHomeTotalOnPowerFlow,
            showInverterIcon: true,
            shouldInvertCT2: false,
            showInverterStationName: showInverterStationName,
            showGridTotalsOnPowerFlow: true,
            showLastUpdateTimestamp: false,
            solarDefinitions: .default(),
            parameterGroups: DefaultParameterGroups(),
            shouldCombineCT2WithPVPower: true,
            showGraphValueDescriptions: true,
            solcastSettings: SolcastSettings(apiKey: nil, sites: []),
            dataCeiling: DataCeiling.mild,
            showTotalYieldOnPowerFlow: true,
            showFinancialSummaryOnFlowPage: true,
            separateParameterGraphsByUnit: true
        )
    }
}
