//
//  Date.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 16/11/2023.
//

import Foundation

public extension Date {
    func isSame(as other: Date) -> Bool {
        let myDate = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let otherDate = Calendar.current.dateComponents([.day, .month, .year], from: other)

        return myDate == otherDate
    }

    func isBefore(rhs: Date) -> Bool {
        let myDate = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let otherDate = Calendar.current.dateComponents([.day, .month, .year], from: rhs)

        if let lhsDate = Calendar.current.date(from: myDate),
           let rhsDate = Calendar.current.date(from: otherDate)
        {
            return lhsDate < rhsDate
        } else {
            return false
        }
    }

    func isAfter(rhs: Date) -> Bool {
        let myDate = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let otherDate = Calendar.current.dateComponents([.day, .month, .year], from: rhs)

        if let lhsDate = Calendar.current.date(from: myDate),
           let rhsDate = Calendar.current.date(from: otherDate)
        {
            return lhsDate > rhsDate
        } else {
            return false
        }
    }

    var date: Date {
        let myDate = Calendar.current.dateComponents([.day, .month, .year], from: self)
        if let lhsDate = Calendar.current.date(from: myDate) {
            return lhsDate
        } else {
            return self
        }
    }

    static func from(year: Int, month: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        let calendar = Calendar.current
        return calendar.date(from: components) ?? Date()
    }

    func hour() -> Int {
        Calendar.current.component(.hour, from: self)
    }
}
