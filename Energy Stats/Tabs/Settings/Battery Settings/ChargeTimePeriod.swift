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
        String(format: String(key: .chargeTimeSummary), arguments: [start.militaryTime(), end.militaryTime()])
    }

    var hasTimes: Bool {
        start.toTime() != .zero() || end.toTime() != .zero()
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
