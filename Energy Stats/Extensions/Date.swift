//
//  Date.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/09/2022.
//

import Foundation

extension Date {
    func militaryTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    static func yesterday() -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: .now)!
    }

    func startOfMonth(using calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    func endOfMonth(using calendar: Calendar = .current) -> Date {
        let start = startOfMonth(using: calendar)
        // Start of next month minus 1 second.
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: start) ?? start
        return calendar.date(byAdding: .second, value: -1, to: nextMonth) ?? self
    }
}

extension DateFormatter {
    static var hourMinuteSecond: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

extension Date.FormatStyle {
    static let dayHour: Date.FormatStyle = .dateTime.day().month(.abbreviated).hour(.twoDigits(amPM: .omitted))
    static let dayMonth: Date.FormatStyle = .dateTime.day().month(.abbreviated)
    static let monthYear: Date.FormatStyle = .dateTime.month(.abbreviated).year()
}

extension Date {
    func dayHourString() -> String { formatted(Date.FormatStyle.dayHour) }
    func dayMonthString() -> String { formatted(Date.FormatStyle.dayMonth) }
    func monthYearString() -> String { formatted(Date.FormatStyle.monthYear) }
}
