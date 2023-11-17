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
}
