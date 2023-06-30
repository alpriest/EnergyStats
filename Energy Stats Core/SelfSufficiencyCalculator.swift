//
//  SelfSufficiencyCalculator.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 26/06/2023.
//

import Foundation

public enum NetSelfSufficiencyCalculator {
    public static func calculate(grid: Double, feedIn: Double, loads: Double, batteryCharge: Double, batteryDischarge: Double) -> Double {
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

        return result.rounded(decimalPlaces: 4)
    }
}

public enum AbsoluteSelfSufficiencyCalculator {
    public static func calculate(loads: Double, grid: Double) -> Double {
        guard loads > 0 else { return 0.0 }

        let result = 1 - (min(loads, max(grid, 0.0)) / loads)

        return result.rounded(decimalPlaces: 4)
    }
}
