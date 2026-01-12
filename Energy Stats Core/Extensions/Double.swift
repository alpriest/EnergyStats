//
//  Double.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 02/05/2023.
//

import SwiftUI

public extension Double {
    func approxEqual(_ b: Double, relativeTolerance: Double = 1e-12, absoluteTolerance: Double = Double.ulpOfOne) -> Bool {
        if self == b { return true } // handles infinities and exact equality quickly
        let diff = abs(self - b)
        // Scale the relative tolerance with the larger magnitude and add an absolute floor
        return diff <= max(relativeTolerance * max(abs(self), abs(b)), absoluteTolerance)
    }
    
    func kW(_ places: Int) -> String {
        let divisor = pow(10.0, Double(places))
        let divided = (self * divisor).rounded() / divisor

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = places
        numberFormatter.maximumFractionDigits = places

        if let formattedString = numberFormatter.string(from: NSNumber(value: divided)) {
            return "\(formattedString) kW"
        } else {
            return "\(divided) kW"
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
            return "\(formattedString) kWh"
        } else {
            return "\(divided) kWh"
        }
    }

    func w() -> String {
        let divided = (self * 1000.0).rounded()

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0

        if let formattedString = numberFormatter.string(from: NSNumber(value: divided)) {
            return "\(formattedString) W"
        } else {
            return "\(divided) W"
        }
    }

    func wh() -> String {
        let divided = (self * 1000.0).rounded()

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0

        if let formattedString = numberFormatter.string(from: NSNumber(value: divided)) {
            return "\(formattedString) Wh"
        } else {
            return "\(divided) Wh"
        }
    }

    func isFlowing() -> Bool {
        rounded(decimalPlaces: 2) != 0.0
    }

    func rounded(decimalPlaces: Int) -> Double {
        let power = pow(10, Double(decimalPlaces))
        return (self * power).rounded() / power
    }

    func roundedToString(decimalPlaces: Int, currencySymbol: String? = nil) -> String {
        let roundedNumber = rounded(decimalPlaces: decimalPlaces)

        let numberFormatter = NumberFormatter()
        if let currencySymbol {
            numberFormatter.numberStyle = .currency
            numberFormatter.currencySymbol = currencySymbol
        }
        numberFormatter.minimumFractionDigits = decimalPlaces
        numberFormatter.maximumFractionDigits = decimalPlaces
        numberFormatter.locale = Locale.current

        return if let formattedString = numberFormatter.string(from: NSNumber(value: roundedNumber)) {
            formattedString
        } else {
            String(format: "%.\(decimalPlaces)f", roundedNumber)
        }
    }

    func percent() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 3
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self))!
    }

    func roundUpToNearestHalf() -> Double {
        ceil(self * 2) / 2
    }

    var tintColor: Color { Int(self).tintColor }
}

public extension Double? {
    var tintColor: Color {
        guard let self else { return Color.primary }
        
        return if self < -0.02 {
            .linesNegative
        } else if self > 0.02 {
            .linesPositive
        } else {
            .iconDisabled
        }
    }
    
    func approxEqual(other: Double) -> Bool {
        guard let self else { return false }
        
        return self.approxEqual(other)
    }
    
    func approxEqual(other: Double?) -> Bool {
        guard let self else { return false }
        guard let other else { return false}
        
        return self.approxEqual(other)
    }
}

public extension Int {
    var tintColor: Color {
        Double(self).tintColor
    }

    func w() -> String {
        return "\(self) W"
    }
}
