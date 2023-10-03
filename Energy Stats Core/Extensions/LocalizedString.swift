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
        case success = "Success"
        case couldNotLogin = "Could not login. Check your internet connection"
        case wrongCredentials = "Wrong credentials, try again"
        case empty = "Empty"
        case full = "Full"
        case nextUpdateIn = "Next update in"
        case launchDataFetchError = "Something went wrong. Please try logging in again."
        case dataFetchError = "data_fetch_error"
        case chargeTimeSummary = "battery_charge_range"
        case noBatteryCharge = "no_battery_charge"
        case bothBatteryChargePeriods = "both_battery_charge_periods"
        case batteryPeriodsOverlap = "battery_periods_overlap"
        case oneBatteryChargePeriod = "one_battery_charge_period"
        case bothBatteryFreezePeriods = "both_battery_freeze_periods"
        case oneBatteryFreezePeriod = "one_battery_freeze_period"
        case inverterSettingsWereSaved = "inverter_settings_saved"
        case batterySOCSettingsWereSaved = "batterySOC_settings_saved"
        case batteryChargeScheduleSettingsWereSaved = "battery_charge_schedule_settings_saved"
        case errorTitle = "error_title"
        case batteryReadError = "battery_read_error"
        case foxessCommunity = "settings.foxessCommunity"
        case facebookGroup = "settings.facebookGroup"
        case debug = "settings.debug"
        case today = "today"
        case month = "month"
        case year = "year"
        case total = "total"
        case tapIconForDetail = "tap_for_detail"
        case breakpoint = "breakpoint"
        case displayUnitKilowattsDescription = "display_unit_kilowatts_description"
        case displayUnitWattsDescription = "display_unit_watts_description"
        case displayUnitAdaptiveDescription = "display_unit_adaptive_description"
        case exportedIncome = "exported_income"
        case importedCost = "imported_cost"
        case gridImportAvoidedShortTitle = "grid_import_avoided_short_title"

        public enum Accessibility: String, RawRepresentable {
            case inverter = "accessibility.inverter"
            case temperature = "accessibility.temperature"
            case currentSolarGenerationAmount = "accessibility.solarGeneration"
            case batteryStoringRate = "accessibility.batteryStoringRate"
            case batteryEmptyingRate = "accessibility.batteryEmptyingRate"
            case batteryCapacityPercentage = "accessibility.batteryCapacityPercentage"
            case batteryCapacity = "accessibility.batteryCapacity"
            case homeConsumptionRate = "accessibility.homeConsumptionRate"
            case gridExportRate = "accessibility.gridExportRate"
            case gridConsumptionRate = "accessibility.gridConsumptionRate"
            case totalYield = "accessibility.yieldToday"
            case batteryTemperature = "accessibility.batteryTemperature"
            case batteryEstimate = "accessibility.batteryEstimate"
            case homeTotalUsageToday = "accessibility.homeTotalUsageToday"
            case totalSolarGenerated = "accessibility.totalSolarGenerated"
            case totalImportedToday = "accessibility.totalImportedToday"
            case totalExportedToday = "accessibility.totalExportedToday"
        }
    }
}

public extension String {
    init(key: LocalizedString.Key, bundle: Bundle = .main) {
        self = NSLocalizedString(key.rawValue, bundle: bundle, comment: "")
    }

    init(key: LocalizedString.Key, bundle: Bundle = .main, arguments: [CVarArg]) {
        self = String(format: NSLocalizedString(key.rawValue, bundle: bundle, comment: ""), arguments: arguments)
    }

    init(accessibilityKey key: LocalizedString.Key.Accessibility) {
        self = NSLocalizedString(key.rawValue, comment: "")
    }
}
