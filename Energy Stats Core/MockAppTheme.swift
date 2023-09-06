//
//  MockAppTheme.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 03/09/2023.
//

import Foundation

public extension AppTheme {
    static func mock(decimalPlaces: Int = 3,
                     showInW: Bool = false,
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
            showInW: showInW,
            showTotalYield: false,
            selfSufficiencyEstimateMode: selfSufficiencyEstimateMode,
            showEarnings: false,
            showInverterTemperature: showInverterTemperature,
            showHomeTotalOnPowerFlow: showHomeTotalOnPowerFlow,
            showInverterIcon: true,
            shouldInvertCT2: false,
            showInverterPlantName: showInverterPlantName,
            showGridTotalsOnPowerFlow: true,
            showInverterTypeNameOnPowerFlow: true,
            showLastUpdateTimestamp: false
        )
    }
}
