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

    public init(
        showColouredLines: Bool,
        showBatteryTemperature: Bool,
        showSunnyBackground: Bool,
        decimalPlaces: Int,
        showBatteryEstimate: Bool,
        showUsableBatteryOnly: Bool,
        showInW: Bool,
        showTotalYield: Bool,
        selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode
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
        selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode? = nil
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
            selfSufficiencyEstimateMode: selfSufficiencyEstimateMode ?? self.selfSufficiencyEstimateMode
        )
    }
}

public typealias LatestAppTheme = CurrentValueSubject<AppTheme, Never>
