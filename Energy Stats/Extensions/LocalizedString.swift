//
//  LocalizedString.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/04/2023.
//

import Foundation

struct LocalizedString {
    enum Key: String, RawRepresentable {
        case loading = "Loading"
        case couldNotLogin = "Could not login. Check your internet connection"
        case wrongCredentials = "Wrong credentials, try again"
        case empty = "Empty"
        case full = "Full"
        case nextUpdateIn = "Next update in"
        case dataFetchError = "Something went wrong and no device was found. Please try logging in again."
        case chargeTimePeriodFailedValidation = "Start time must be before the end time"
        case chargeTimeSummary = "battery_charge_range"
    }
}

extension String {
    init(key: LocalizedString.Key) {
        self = NSLocalizedString(key.rawValue, comment: "")
    }
}
