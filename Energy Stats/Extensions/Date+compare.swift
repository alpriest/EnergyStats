//
//  Date+compare.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/04/2023.
//

import Foundation

extension Date {
    func isSame(as other: Date) -> Bool {
        let myDate = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let otherDate = Calendar.current.dateComponents([.day, .month, .year], from: other)

        return myDate == otherDate
    }
}
