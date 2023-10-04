//
//  AppTheme.swift
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

public struct AppTheme {
    public var showColouredLines: Bool
    public var showBatteryTemperature: Bool
    public var showSunnyBackground: Bool
    public var decimalPlaces: Int
    public var showBatteryEstimate: Bool
    public var showUsableBatteryOnly: Bool
    public var displayUnit: DisplayUnit
    public var showTotalYield: Bool
    public var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode
    public var showFinancialEarnings: Bool
    public var financialModel: FinancialModel
    public var feedInUnitPrice: Double
    public var gridImportUnitPrice: Double
    public var showInverterTemperature: Bool
    public var showHomeTotalOnPowerFlow: Bool
    public var showInverterIcon: Bool
    public var shouldInvertCT2: Bool
    public var showInverterPlantName: Bool
    public var showGridTotalsOnPowerFlow: Bool
    public var showInverterTypeNameOnPowerFlow: Bool
    public var showLastUpdateTimestamp: Bool
    public var solarDefinitions: SolarRangeDefinitions
    public var parameterGroups: [ParameterGroup]

    public init(
        showColouredLines: Bool,
        showBatteryTemperature: Bool,
        showSunnyBackground: Bool,
        decimalPlaces: Int,
        showBatteryEstimate: Bool,
        showUsableBatteryOnly: Bool,
        displayUnit: DisplayUnit,
        showTotalYield: Bool,
        selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode,
        showFinancialEarnings: Bool,
        financialModel: FinancialModel,
        feedInUnitPrice: Double,
        gridImportUnitPrice: Double,
        showInverterTemperature: Bool,
        showHomeTotalOnPowerFlow: Bool,
        showInverterIcon: Bool,
        shouldInvertCT2: Bool,
        showInverterPlantName: Bool,
        showGridTotalsOnPowerFlow: Bool,
        showInverterTypeNameOnPowerFlow: Bool,
        showLastUpdateTimestamp: Bool,
        solarDefinitions: SolarRangeDefinitions,
        parameterGroups: [ParameterGroup]
    ) {
        self.showColouredLines = showColouredLines
        self.showBatteryTemperature = showBatteryTemperature
        self.showSunnyBackground = showSunnyBackground
        self.decimalPlaces = decimalPlaces
        self.showBatteryEstimate = showBatteryEstimate
        self.showUsableBatteryOnly = showUsableBatteryOnly
        self.displayUnit = displayUnit
        self.showTotalYield = showTotalYield
        self.selfSufficiencyEstimateMode = selfSufficiencyEstimateMode
        self.showFinancialEarnings = showFinancialEarnings
        self.financialModel = financialModel
        self.feedInUnitPrice = feedInUnitPrice
        self.gridImportUnitPrice = gridImportUnitPrice
        self.showInverterTemperature = showInverterTemperature
        self.showHomeTotalOnPowerFlow = showHomeTotalOnPowerFlow
        self.showInverterIcon = showInverterIcon
        self.shouldInvertCT2 = shouldInvertCT2
        self.showInverterPlantName = showInverterPlantName
        self.showGridTotalsOnPowerFlow = showGridTotalsOnPowerFlow
        self.showInverterTypeNameOnPowerFlow = showInverterTypeNameOnPowerFlow
        self.showLastUpdateTimestamp = showLastUpdateTimestamp
        self.solarDefinitions = solarDefinitions
        self.parameterGroups = parameterGroups
    }

    public func copy(
        showColouredLines: Bool? = nil,
        showBatteryTemperature: Bool? = nil,
        showSunnyBackground: Bool? = nil,
        decimalPlaces: Int? = nil,
        showBatteryEstimate: Bool? = nil,
        showUsableBatteryOnly: Bool? = nil,
        displayUnit: DisplayUnit? = nil,
        showTotalYield: Bool? = nil,
        selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode? = nil,
        showFinancialEarnings: Bool? = nil,
        financialModel: FinancialModel? = nil,
        feedInUnitPrice: Double? = nil,
        gridImportUnitPrice: Double? = nil,
        showInverterTemperature: Bool? = nil,
        showHomeTotalOnPowerFlow: Bool? = nil,
        showInverterIcon: Bool? = nil,
        shouldInvertCT2: Bool? = nil,
        showInverterPlantName: Bool? = nil,
        showGridTotalsOnPowerFlow: Bool? = nil,
        showInverterTypeNameOnPowerFlow: Bool? = nil,
        showLastUpdateTimestamp: Bool? = nil,
        solarDefinitions: SolarRangeDefinitions? = nil,
        parameterGroups: [ParameterGroup]? = nil
    ) -> AppTheme {
        AppTheme(
            showColouredLines: showColouredLines ?? self.showColouredLines,
            showBatteryTemperature: showBatteryTemperature ?? self.showBatteryTemperature,
            showSunnyBackground: showSunnyBackground ?? self.showSunnyBackground,
            decimalPlaces: decimalPlaces ?? self.decimalPlaces,
            showBatteryEstimate: showBatteryEstimate ?? self.showBatteryEstimate,
            showUsableBatteryOnly: showUsableBatteryOnly ?? self.showUsableBatteryOnly,
            displayUnit: displayUnit ?? self.displayUnit,
            showTotalYield: showTotalYield ?? self.showTotalYield,
            selfSufficiencyEstimateMode: selfSufficiencyEstimateMode ?? self.selfSufficiencyEstimateMode,
            showFinancialEarnings: showFinancialEarnings ?? self.showFinancialEarnings,
            financialModel: financialModel ?? self.financialModel,
            feedInUnitPrice: feedInUnitPrice ?? self.feedInUnitPrice,
            gridImportUnitPrice: gridImportUnitPrice ?? self.gridImportUnitPrice,
            showInverterTemperature: showInverterTemperature ?? self.showInverterTemperature,
            showHomeTotalOnPowerFlow: showHomeTotalOnPowerFlow ?? self.showHomeTotalOnPowerFlow,
            showInverterIcon: showInverterIcon ?? self.showInverterIcon,
            shouldInvertCT2: shouldInvertCT2 ?? self.shouldInvertCT2,
            showInverterPlantName: showInverterPlantName ?? self.showInverterPlantName,
            showGridTotalsOnPowerFlow: showGridTotalsOnPowerFlow ?? self.showGridTotalsOnPowerFlow,
            showInverterTypeNameOnPowerFlow: showInverterTypeNameOnPowerFlow ?? self.showInverterTypeNameOnPowerFlow,
            showLastUpdateTimestamp: showLastUpdateTimestamp ?? self.showLastUpdateTimestamp,
            solarDefinitions: solarDefinitions ?? self.solarDefinitions,
            parameterGroups: parameterGroups ?? self.parameterGroups
        )
    }
}

public typealias LatestAppTheme = CurrentValueSubject<AppTheme, Never>
