//
//  LocalizedString.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/04/2023.
//

import Foundation

public struct LocalizedString {
    public enum Key: String, RawRepresentable {
        case loading = "Loading"
        case saving = "Saving"
        case couldNotLogin = "Could not login. Check your internet connection"
        case wrongCredentials = "Wrong credentials, try again"
        case empty = "Empty"
        case full = "Full"
        case nextUpdateIn = "Next update in"
        case dataFetchError = "Something went wrong and no device was found. Please try logging in again."
        case chargeTimePeriodFailedValidation = "Start time must be before the end time"
        case chargeTimeSummary = "battery_charge_range"
        case noBatteryCharge = "no_battery_charge"
        case bothBatteryChargePeriods = "both_battery_charge_periods"
        case batteryPeriodsOverlap = "battery_periods_overlap"
        case oneBatteryChargePeriod = "one_battery_charge_period"
        case bothBatteryFreezePeriods = "both_battery_freeze_periods"
        case oneBatteryFreezePeriod = "one_battery_freeze_period"

        public enum Accessibility: String, RawRepresentable {
            case inverter = "accessibility.inverter"
            case temperature = "accessibility.temperature"
            case currentSolarGenerationAmount = "accessibility.solarGeneration"
            case batteryStoringRate = "accessibility.batteryStoringRate"
            case batteryEmptyingRate = "accessibility.batteryEmptyingRate"
            case batteryCapacity = "accessibility.batteryCapacity"
            case homeConsumptionRate = "accessibility.homeConsumptionRate"
            case gridExportRate = "accessibility.gridExportRate"
            case gridConsumptionRate = "accessibility.gridConsumptionRate"
            case totalYield = "accessibility.yieldToday"
        }
    }
}

public extension String {
    init(key: LocalizedString.Key) {
        self = NSLocalizedString(key.rawValue, comment: "")
    }

    init(accessibilityKey key: LocalizedString.Key.Accessibility) {
        self = NSLocalizedString(key.rawValue, comment: "")
    }
}
