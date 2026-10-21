//
//  StatsGraphDisplayMode.swift
//  Energy Stats
//
//  Created by Alistair Priest on 01/02/2026.
//

import Charts
import Combine
import Energy_Stats_Core
import SwiftUI

enum StatsGraphDisplayMode: Equatable {
    case day(Date)
    case month(_ month: Int, _ year: Int)
    case year(Int)
    case custom(_ start: Date, _ end: Date, _ unit: CustomDateRangeDisplayUnit)

    func unit() -> Calendar.Component {
        switch self {
        case .day:
            .hour
        case .month:
            .day
        case .year:
            .month
        case let .custom(_, _, unit):
            switch unit {
            case .days:
                .day
            case .months:
                .month
            }
        }
    }

    static func ==(lhs: StatsGraphDisplayMode, rhs: StatsGraphDisplayMode) -> Bool {
        switch (lhs, rhs) {
        case let (.day(lDate), .day(rDate)):
            return lDate.isSame(as: rDate)
        case let (.month(lMonth, lYear), .month(rMonth, rYear)):
            return lYear == rYear && lMonth == rMonth
        case let (.year(lYear), .year(rYear)):
            return lYear == rYear
        default:
            return false
        }
    }
}

extension StatsGraphDisplayMode {
    var dateInterval: DateInterval {
        let calendar = Calendar.current
        let start: Date
        let end: Date

        switch self {
        case .day(let date):
            start = calendar.startOfDay(for: date)
            end = calendar.date(byAdding: .day, value: 1, to: start)!
        case .month(let month, let year):
            start = Date.from(year: year, month: month).startOfMonth()
            end = calendar.date(byAdding: .month, value: 1, to: start)!
        case .year(let year):
            start = Date.from(year: year, month: 1).startOfYear()
            end = calendar.date(byAdding: .year, value: 1, to: start)!
        case .custom(let customStart, let customEnd, _):
            start = calendar.startOfDay(for: customStart)
            end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: customEnd))!
        }

        return DateInterval(start: start, end: end)
    }
}
