//
//  BatteryCapacityCalculator.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Foundation

public class BatteryCapacityCalculator {
    private let capacityW: Double
    private let formatter = RelativeDateTimeFormatter()
    private let minimumSOC: Double
    private let percentageConsideredFull = 98.75

    public init(capacityW: Int, minimumSOC: Double) {
        self.capacityW = Double(capacityW)
        self.minimumSOC = minimumSOC
    }

    private var minimumCharge: Double {
        capacityW * minimumSOC
    }

    public func batteryChargeStatusDescription(batteryChargePowerkWH: Double, batteryStateOfCharge: Double) -> String? {
        guard abs(batteryChargePowerkWH) > 0 else { return nil }
        
        let currentEstimatedCharge = capacityW * batteryStateOfCharge

        if batteryChargePowerkWH > 0 { // battery charging
            if batteryStateOfCharge >= percentageConsideredFull { return nil }

            let capacityRemaining = capacityW - currentEstimatedCharge
            let minsToFullCharge = (capacityRemaining / (batteryChargePowerkWH * 1000.0)) * 60 * 60
            let duration = formatter.localizedString(fromTimeInterval: minsToFullCharge)

            return String(key: .full) + " \(duration)"
        } else { // battery emptying
            if batteryStateOfCharge <= (minimumSOC * 1.02) { return nil }
            let chargeRemaining = currentEstimatedCharge - minimumCharge
            let minsUntilEmpty = (chargeRemaining / abs(batteryChargePowerkWH * 1000.0)) * 60 * 60
            let duration = formatter.localizedString(fromTimeInterval: minsUntilEmpty)

            return String(key: .empty) + " \(duration)"
        }
    }

    public func currentEstimatedChargeAmountWh(batteryStateOfCharge: Double, includeUnusableCapacity: Bool = true) -> Double {
        (capacityW * batteryStateOfCharge) - (includeUnusableCapacity ? 0 : minimumCharge)
    }

    public func effectiveBatteryStateOfCharge(batteryStateOfCharge: Double, includeUnusableCapacity: Bool = true) -> Double {
        guard batteryStateOfCharge <= percentageConsideredFull else { return 0.99 }

        let deduction = includeUnusableCapacity ? 0 : minimumSOC
        return ((batteryStateOfCharge - deduction) / (1 - deduction)).rounded(decimalPlaces: 2)
    }
}