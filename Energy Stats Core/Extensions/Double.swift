//
//  Double.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 02/05/2023.
//

import Foundation

public extension Double {
    func kW(_ places: Int) -> String {
        let divisor = pow(10.0, Double(places))
        let divided = (self * divisor).rounded() / divisor

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = places
        numberFormatter.maximumFractionDigits = places

        if let formattedString = numberFormatter.string(from: NSNumber(value: divided)) {
            return "\(formattedString)kW"
        } else {
            return "\(divided)kW"
        }
    }

    func kWh(_ places: Int) -> String {
        let divisor = pow(10.0, Double(places))
        let divided = (self * divisor).rounded() / divisor

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = places
        numberFormatter.maximumFractionDigits = places

        if let formattedString = numberFormatter.string(from: NSNumber(value: divided)) {
            return "\(formattedString)kWh"
        } else {
            return "\(divided)kWh"
        }
    }

    func w() -> String {
        let divided = (self * 1000.0).rounded()

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0

        if let formattedString = numberFormatter.string(from: NSNumber(value: divided)) {
            return "\(formattedString)W"
        } else {
            return "\(divided)W"
        }
    }

    func wh() -> String {
        let divided = (self * 1000.0).rounded()

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0

        if let formattedString = numberFormatter.string(from: NSNumber(value: divided)) {
            return "\(formattedString)Wh"
        } else {
            return "\(divided)Wh"
        }
    }

    func rounded(decimalPlaces: Int) -> Double {
        let power = pow(10, Double(decimalPlaces))
        return (self * power).rounded() / power
    }

    func percent() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 3
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self))!
    }
}
