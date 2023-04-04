//
//  BatteryCapacityCalculator.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Foundation

class BatteryCapacityCalculator {
    private let capacityW: Double
    private let formatter = RelativeDateTimeFormatter()
    private let minimumSOC: Double
    private let percentageConsideredFull = 98.75

    init(capacityW: Int, minimumSOC: Double) {
        self.capacityW = Double(capacityW)
        self.minimumSOC = minimumSOC
    }

    private var minimumCharge: Double {
        capacityW * minimumSOC
    }

    func batteryChargeStatusDescription(batteryChargePowerkWH: Double, batteryStateOfCharge: Double) -> String? {
        guard abs(batteryChargePowerkWH) > 0 else { return nil }
        
        let currentEstimatedCharge = capacityW * batteryStateOfCharge

        if batteryChargePowerkWH > 0 { // battery charging
            if batteryStateOfCharge >= percentageConsideredFull { return nil }

            let capacityRemaining = capacityW - currentEstimatedCharge
            let minsToFullCharge = (capacityRemaining / (batteryChargePowerkWH * 1000.0)) * 60 * 60
            let duration = formatter.localizedString(fromTimeInterval: minsToFullCharge)

            return "Full \(duration)"
        } else { // battery emptying
            if batteryStateOfCharge <= (minimumSOC * 1.02) { return nil }
            let chargeRemaining = currentEstimatedCharge - minimumCharge
            let minsUntilEmpty = (chargeRemaining / abs(batteryChargePowerkWH * 1000.0)) * 60 * 60
            let duration = formatter.localizedString(fromTimeInterval: minsUntilEmpty)

            return "Empty \(duration)"
        }
    }

    func currentEstimatedChargeAmountW(batteryStateOfCharge: Double, includeUnusableCapacity: Bool = true) -> Double {
        (capacityW * batteryStateOfCharge) - (includeUnusableCapacity ? 0 : minimumCharge)
    }

    func effectiveBatteryStateOfCharge(batteryStateOfCharge: Double, includeUnusableCapacity: Bool = true) -> Double {
        guard batteryStateOfCharge <= percentageConsideredFull else { return 0.99 }

        let effectiveBatteryCapacity = effectiveBatteryCapacityW(includeUnusableCapacity: includeUnusableCapacity)
        let actualEstimatedStoredCharge = capacityW * batteryStateOfCharge
        let effectiveEstimatedStoredCharge = actualEstimatedStoredCharge - (includeUnusableCapacity ? 0 : minimumCharge)

        return max(effectiveEstimatedStoredCharge / effectiveBatteryCapacity, 0)
    }

    private func effectiveBatteryCapacityW(includeUnusableCapacity: Bool = true) -> Double {
        capacityW - (includeUnusableCapacity ? 0 : minimumCharge)
    }
}
