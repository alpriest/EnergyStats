//
//  BatteryCapacityCalculator.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Foundation

class BatteryCapacityCalculator {
    private let capacitykW: Double
    private let formatter = RelativeDateTimeFormatter()
    private let minimumSOC: Double

    init(capacitykW: Double, minimumSOC: Double) {
        self.capacitykW = capacitykW
        self.minimumSOC = minimumSOC
    }

    var minimumCharge: Double {
        capacitykW * minimumSOC
    }

    func batteryRemaining(batteryChargePowerkWH: Double, batteryStateOfCharge: Double) -> String? {
        let currentEstimatedCharge = capacitykW * batteryStateOfCharge

        if batteryChargePowerkWH > 0 { // battery charging
            if batteryStateOfCharge >= 98.99 { return nil }

            let capacityRemaining = capacitykW - currentEstimatedCharge
            let minsToFullCharge = (capacityRemaining / (batteryChargePowerkWH * 1000.0)) * 60 * 60
            let duration = formatter.localizedString(fromTimeInterval: minsToFullCharge)

            return "Full \(duration)"
        } else { // battery emptying
            if batteryStateOfCharge <= (minimumSOC * 1.03) { return nil }
            let chargeRemaining = currentEstimatedCharge - minimumCharge
            let minsUntilEmpty = (chargeRemaining / abs(batteryChargePowerkWH * 1000.0)) * 60 * 60
            let duration = formatter.localizedString(fromTimeInterval: minsUntilEmpty)

            return "Empty \(duration)"
        }
    }
}
