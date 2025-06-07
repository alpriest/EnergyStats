//
//  String+Double.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/05/2025.
//

import Foundation

public extension String {
    func removingEmptyDecimals() -> String {
        if let value = Double(self) {
            let cleaned = value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
            return cleaned
        } else {
            return self
        }
    }
}
