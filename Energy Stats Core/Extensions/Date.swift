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
           let rhsDate = Calendar.current.date(from: otherDate) {

            return lhsDate < rhsDate
        } else {
            return false
        }
    }

    func isAfter(rhs: Date) -> Bool {
        let myDate = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let otherDate = Calendar.current.dateComponents([.day, .month, .year], from: rhs)

        if let lhsDate = Calendar.current.date(from: myDate),
           let rhsDate = Calendar.current.date(from: otherDate) {

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
}
