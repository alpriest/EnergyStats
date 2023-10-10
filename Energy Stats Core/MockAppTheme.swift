//
//  MockAppTheme.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 03/09/2023.
//

import Foundation

public extension AppTheme {
    static func mock(decimalPlaces: Int = 3,
                     displayUnit: DisplayUnit = .kilowatt,
                     showInverterTemperature: Bool = true,
                     selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode = .off,
                     showHomeTotalOnPowerFlow: Bool = true,
                     showInverterPlantName: Bool = false) -> AppTheme {
        AppTheme(
            showColouredLines: true,
            showBatteryTemperature: true,
            showSunnyBackground: true,
            decimalPlaces: decimalPlaces,
            showBatteryEstimate: true,
            showUsableBatteryOnly: false,
            displayUnit: displayUnit,
            showTotalYield: false,
            selfSufficiencyEstimateMode: selfSufficiencyEstimateMode,
            showFinancialEarnings: false,
            financialModel: .energyStats,
            feedInUnitPrice: 0.05,
            gridImportUnitPrice: 0.15,
            showInverterTemperature: showInverterTemperature,
            showHomeTotalOnPowerFlow: showHomeTotalOnPowerFlow,
            showInverterIcon: true,
            shouldInvertCT2: false,
            showInverterPlantName: showInverterPlantName,
            showGridTotalsOnPowerFlow: true,
            showInverterTypeNameOnPowerFlow: true,
            showLastUpdateTimestamp: false,
            solarDefinitions: .default(),
            parameterGroups: DefaultParameterGroups(),
            shouldCombineCT2WithPVPower: true
        )
    }
}
