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
        formatter.dateFormat = "HH:00"
        return formatter.string(from: self)
    }

    static func yesterday() -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: .now)!
    }
}
