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
            refreshFrequency: .AUTO,
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
            solcastSettings: SolcastSettings(apiKey: "1234", sites: [
                SolcastSite(name: "name", resourceId: "res123", lng: 53.3, lat: -2.48, azimuth: 1, tilt: 0.0, lossFactor: nil, acCapacity: 2.0, dcCapacity: nil, installDate: nil)
            ]),
            dataCeiling: DataCeiling.mild,
            showTotalYieldOnPowerFlow: true,
            showFinancialSummaryOnFlowPage: true,
            separateParameterGraphsByUnit: true,
            currencySymbol: "£",
            showInverterTypeName: false,
            powerFlowStrings: .none,
            showBatteryPercentageRemaining: true,
            showSelfSufficiencyStatsGraphOverlay: true,
            truncatedYAxisOnParameterGraphs: true,
            earningsModel: .exported,
            minSOC: 0.2,
            batteryTemperatureDisplayMode: .automatic,
            showInverterScheduleQuickLink: true,
            fetchSolcastOnAppLaunch: false,
            ct2DisplayMode: .hidden,
            shouldCombineCT2WithLoadsPower: false
        )
    }
}
