//
//  String+Currency.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 07/10/2023.
//

import Foundation

public extension String {
    func asCurrencyStringToDouble(locale: Locale = Locale.current) -> Double {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = locale
        numberFormatter.numberStyle = .currency

        if let number = numberFormatter.number(from: self) {
            return number.doubleValue
        } else {
            let alternateFormatter = NumberFormatter()
            alternateFormatter.locale = locale
            alternateFormatter.numberStyle = .decimal

            if let alternateNumber = alternateFormatter.number(from: self) {
                return alternateNumber.doubleValue
            } else {
                return 0.0
            }
        }
    }
}
