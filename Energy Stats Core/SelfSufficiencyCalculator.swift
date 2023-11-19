//
//  SelfSufficiencyCalculator.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 26/06/2023.
//

import Foundation

public enum NetSelfSufficiencyCalculator {
    public static func calculate(grid: Double, feedIn: Double, loads: Double, batteryCharge: Double, batteryDischarge: Double) -> (Double, CalculationBreakdown) {
        let netGeneration = feedIn - grid + batteryCharge - batteryDischarge
        let homeConsumption = loads

        var result: Double = 0
        if netGeneration > 0 {
            result = 1
        } else if netGeneration + homeConsumption < 0 {
            result = 0
        } else if netGeneration + homeConsumption > 0 {
            result = (netGeneration + homeConsumption) / homeConsumption
        }

        let breakdown = CalculationBreakdown(
            formula: """
                     netGeneration = feedIn - grid + batteryCharge - batteryDischarge

                     If netGeneration > 0 then result = 1
                     Else if netGeneration + homeConsumption < 0 then result = 0
                     Else if netGeneration + homeConsumption > 0 then result = (netGeneration + homeConsumption) / homeConsumption
                     """,
            calculation: { dp in """
                     netGeneration = \(feedIn.roundedToString(decimalPlaces: dp)) - \(grid.roundedToString(decimalPlaces: dp)) + \(batteryCharge.roundedToString(decimalPlaces: dp)) - \(batteryDischarge.roundedToString(decimalPlaces: dp))

                     If \(netGeneration.roundedToString(decimalPlaces: dp)) > 0 then result = 1
                     Else if \(netGeneration.roundedToString(decimalPlaces: dp)) + \(loads.roundedToString(decimalPlaces: dp)) < 0 then result = 0
                     Else if \(netGeneration.roundedToString(decimalPlaces: dp)) + \(loads.roundedToString(decimalPlaces: dp)) > 0 then result = (\(netGeneration.roundedToString(decimalPlaces: dp)) + \(loads.roundedToString(decimalPlaces: dp))) / \(loads.roundedToString(decimalPlaces: dp))
                     """}
        )

        return (result.rounded(decimalPlaces: 4), breakdown)
    }
}

public enum AbsoluteSelfSufficiencyCalculator {
    public static func calculate(loads: Double, grid: Double) -> (Double, CalculationBreakdown) {
        let formula = "1 - (min(loads, max(grid, \(0.roundedToString(decimalPlaces: 2))) / loads)"
        guard loads > 0 else { return (0.0, CalculationBreakdown(formula: formula, calculation: { _ in "" })) }

        let result = 1 - (min(loads, max(grid, 0.0)) / loads)

        let breakdown = CalculationBreakdown(
            formula: formula,
            calculation: { dp in "1 - (min(\(loads.roundedToString(decimalPlaces: dp)), max(\(grid.roundedToString(decimalPlaces: dp)), \(0.0.roundedToString(decimalPlaces: dp))) / \(loads.roundedToString(decimalPlaces: dp))" }
        )

        return (result.rounded(decimalPlaces: 4), breakdown)
    }
}
