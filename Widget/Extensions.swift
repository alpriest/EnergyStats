//
//  Extensions.swift
//  WidgetExtension
//
//  Created by Alistair Priest on 15/06/2023.
//

import Energy_Stats_Core
import SwiftUI

extension AppTheme {
    func lineColor(for amount: Double, showColour: Bool) -> Color {
        if amount.isNonZero, self.showColouredLines, showColour {
            if amount > 0 {
                return .linesPositive
            } else {
                return .linesNegative
            }
        } else {
            return .linesNotFlowing
        }
    }

    func textColor(for amount: Double, showColour: Bool) -> Color {
        if amount.isNonZero, showColouredLines && showColour {
            if amount > 0 {
                return .textPositive
            } else {
                return .textNegative
            }
        } else {
            return .textNotFlowing
        }
    }
}

extension Double {
    var isNonZero: Bool {
        rounded(decimalPlaces: 2) != 0.0
    }
}
