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
    public var showInW: Bool
    public var showTotalYield: Bool
    public var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode
    public var showEarnings: Bool
    public var showInverterTemperature: Bool
    public var showHomeTotal: Bool
    public var showInverterIcon: Bool
    public var shouldInvertCT2: Bool

    public init(
        showColouredLines: Bool,
        showBatteryTemperature: Bool,
        showSunnyBackground: Bool,
        decimalPlaces: Int,
        showBatteryEstimate: Bool,
        showUsableBatteryOnly: Bool,
        showInW: Bool,
        showTotalYield: Bool,
        selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode,
        showEarnings: Bool,
        showInverterTemperature: Bool,
        showHomeTotal: Bool,
        showInverterIcon: Bool,
        shouldInvertCT2: Bool
    ) {
        self.showColouredLines = showColouredLines
        self.showBatteryTemperature = showBatteryTemperature
        self.showSunnyBackground = showSunnyBackground
        self.decimalPlaces = decimalPlaces
        self.showBatteryEstimate = showBatteryEstimate
        self.showUsableBatteryOnly = showUsableBatteryOnly
        self.showInW = showInW
        self.showTotalYield = showTotalYield
        self.selfSufficiencyEstimateMode = selfSufficiencyEstimateMode
        self.showEarnings = showEarnings
        self.showInverterTemperature = showInverterTemperature
        self.showHomeTotal = showHomeTotal
        self.showInverterIcon = showInverterIcon
        self.shouldInvertCT2 = shouldInvertCT2
    }

    public func update(
        showColouredLines: Bool? = nil,
        showBatteryTemperature: Bool? = nil,
        showSunnyBackground: Bool? = nil,
        decimalPlaces: Int? = nil,
        showBatteryEstimate: Bool? = nil,
        showUsableBatteryOnly: Bool? = nil,
        showInW: Bool? = nil,
        showTotalYield: Bool? = nil,
        selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode? = nil,
        showEarnings: Bool? = nil,
        showInverterTemperature: Bool? = nil,
        showHomeTotal: Bool? = nil,
        showInverterIcon: Bool? = nil,
        shouldInvertCT2: Bool? = nil
    ) -> AppTheme {
        AppTheme(
            showColouredLines: showColouredLines ?? self.showColouredLines,
            showBatteryTemperature: showBatteryTemperature ?? self.showBatteryTemperature,
            showSunnyBackground: showSunnyBackground ?? self.showSunnyBackground,
            decimalPlaces: decimalPlaces ?? self.decimalPlaces,
            showBatteryEstimate: showBatteryEstimate ?? self.showBatteryEstimate,
            showUsableBatteryOnly: showUsableBatteryOnly ?? self.showUsableBatteryOnly,
            showInW: showInW ?? self.showInW,
            showTotalYield: showTotalYield ?? self.showTotalYield,
            selfSufficiencyEstimateMode: selfSufficiencyEstimateMode ?? self.selfSufficiencyEstimateMode,
            showEarnings: showEarnings ?? self.showEarnings,
            showInverterTemperature: showInverterTemperature ?? self.showInverterTemperature,
            showHomeTotal: showHomeTotal ?? self.showHomeTotal,
            showInverterIcon: showInverterIcon ?? self.showInverterIcon,
            shouldInvertCT2: shouldInvertCT2 ?? self.shouldInvertCT2
        )
    }
}

public typealias LatestAppTheme = CurrentValueSubject<AppTheme, Never>
