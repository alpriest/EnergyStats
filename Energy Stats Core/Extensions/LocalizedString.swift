//
//  LocalizedString.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/04/2023.
//

import Foundation

public struct LocalizedString {
    public enum Key: String, RawRepresentable {
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
        case exportedIncomeShortTitle = "exported_income_short_title"
        case generatedIncomeShortTitle = "generated_income_short_title"
        case exportedIncomeLongTitle = "export_income"
        case generationIncomeLongTitle = "generation_income"
        case gridImportAvoidedShortTitle = "grid_import_avoided_short_title"
        case dataCeilingNone = "data_ceiling_none"
        case dataCeilingMild = "data_ceiling_mild"
        case dataCeilingEnhanced = "data_ceiling_enhanced"
        case schedulesUnsupported = "schedules_unsupported"
        case batteryTemperatureDisplayMode_automatic = "batteryTemperatureDisplayMode_automatic"
        case batteryTemperatureDisplayMode_batteryN = "batteryTemperatureDisplayMode_batteryN"
        case scheduleError44098 = "Fox Cloud error 44098. Could not save schedule. This may be because Fox do not support MaxSOC on OpenAPI."

        public enum Accessibility: String, RawRepresentable {
            case inverter = "accessibility.inverter"
            case temperature = "accessibility.temperature"
            case currentSolarStringGenerationAmount = "accessibility.solarStringGeneration"
            case currentSolarGenerationAmount = "accessibility.solarGeneration"
            case currentSolarCT2GenerationAmount = "accessibility.solarCT2Generation"
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
            case totalExportIncomeToday = "accessibility.totalExportIncomeToday"
            case totalGeneratedIncomeToday = "accessibility.totalGeneratedIncomeToday"
            case totalAvoidedCostsToday = "accessibility.totalAvoidedCostsToday"
            case totalIncomeToday = "accessibility.totalIncomeToday"
            case minutes = "accessibility.minutes"
            case seconds = "accessibility.seconds"
        }
    }
}

public extension String {
    init(key: LocalizedString.Key, bundle: Bundle = .main) {
        self = NSLocalizedString(key.rawValue, bundle: bundle, comment: "")
    }

    init(key: LocalizedString.Key, bundle: Bundle = .main, arguments: CVarArg...) {
        self = String(format: NSLocalizedString(key.rawValue, bundle: bundle, comment: ""), arguments: arguments)
    }

    init(accessibilityKey key: LocalizedString.Key.Accessibility, bundle: Bundle = .main) {
        self = NSLocalizedString(key.rawValue, bundle: bundle, comment: "")
    }
}
