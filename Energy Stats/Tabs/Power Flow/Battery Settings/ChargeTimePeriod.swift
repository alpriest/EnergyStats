//
//  ChargeTimePeriod.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import Energy_Stats_Core
import Foundation

struct ChargeTimePeriod: Equatable {
    var start: Date
    var end: Date
    var enabled: Bool

    init(start: Date, end: Date, enabled: Bool) {
        self.start = start
        self.end = end
        self.enabled = enabled
    }

    init(startTime: Time, endTime: Time, enabled: Bool) {
        self.init(start: Date.fromTime(startTime), end: Date.fromTime(endTime), enabled: enabled)
    }

    var description: String {
        if enabled {
            return String(format: String(key: .chargeTimeSummary), arguments: [start.militaryTime(), end.militaryTime()])
        } else {
            return ""
        }
    }

    var validate: String? {
        if !enabled { return nil }

        if start > end {
            return String(key: .chargeTimePeriodFailedValidation)
        }

        return nil
    }

    var valid: Bool {
        !enabled || (enabled && validate == nil)
    }

    func asChargeTime() -> ChargeTime {
        ChargeTime(enableGrid: enabled,
                   startTime: start.toTime(),
                   endTime: end.toTime())
    }

    func overlaps(_ otherPeriod: ChargeTimePeriod) -> Bool {
        let thisPeriod = asChargeTime()
        let otherPeriod = otherPeriod.asChargeTime()

        return !(thisPeriod.endTime.hour < otherPeriod.startTime.hour ||
                 (thisPeriod.endTime.hour == otherPeriod.startTime.hour && thisPeriod.endTime.minute <= otherPeriod.startTime.minute) ||
                 thisPeriod.startTime.hour > otherPeriod.endTime.hour ||
                 (thisPeriod.startTime.hour == otherPeriod.endTime.hour && thisPeriod.startTime.minute >= otherPeriod.endTime.minute))
    }
}

extension Date {
    static func zero() -> Date {
        guard let result = Calendar.current.date(bySetting: .hour, value: 0, of: .now) else { return .now }
        return Calendar.current.date(bySetting: .minute, value: 0, of: result) ?? .now
    }

    static func fromTime(_ time: Time) -> Date {
        guard let result = Calendar.current.date(bySetting: .hour, value: time.hour, of: .now) else { return .now }
        return Calendar.current.date(bySetting: .minute, value: time.minute, of: result) ?? .now
    }

    func toTime() -> Time {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self)

        return Time(hour: components.hour ?? 0,
                    minute: components.minute ?? 0)
    }
}
