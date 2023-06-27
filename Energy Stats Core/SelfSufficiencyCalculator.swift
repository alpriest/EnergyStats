//
//  SelfSufficiencyCalculator.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 26/06/2023.
//

import Foundation

public final class SelfSufficiencyCalculator {
    public init() {}

    public func calculate(generation: Double, feedIn: Double, grid: Double, batteryCharge: Double, batteryDischarge: Double) -> Double {
        let homeConsumption = generation - feedIn + grid + batteryDischarge - batteryCharge
        let selfServedPower = generation + batteryDischarge

        let result = max(0.0, min(1.0, (selfServedPower / homeConsumption))) - (grid / homeConsumption)

        return result.rounded(decimalPlaces: 3)
    }
}
