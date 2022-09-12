//
//  PowerFlowViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import Foundation

struct PowerFlowViewModel {
    let solar: Double
    let battery: Double
    let home: Double
    let grid: Double
    let batteryStateOfCharge: Double

    var batteryExtra: String? {
        BatteryCalculator(capacitykW: 7.8).batteryRemaining(batteryChargePowerkWH: battery, batteryStartOfCharge: batteryStateOfCharge)
    }
}

class BatteryCalculator {
    private let capacitykW: Double
    private let formatter = RelativeDateTimeFormatter()

    init(capacitykW: Double) {
        self.capacitykW = capacitykW
    }

    var minimumCharge: Double {
        capacitykW * 0.2
    }

    func batteryRemaining(batteryChargePowerkWH: Double, batteryStartOfCharge: Double) -> String? {
        let currentEstimatedCharge = capacitykW * batteryStartOfCharge

        if batteryChargePowerkWH > 0 { // battery charging
            if batteryStartOfCharge >= 99 { return nil }

            let capacityRemaining = capacitykW - currentEstimatedCharge
            let minsToFullCharge = (capacityRemaining / batteryChargePowerkWH) * 60 * 60
            let duration = formatter.localizedString(fromTimeInterval: minsToFullCharge)

            return "Full \(duration)"
        } else { // battery emptying
            let chargeRemaining = currentEstimatedCharge - minimumCharge
            let minsUntilEmpty = (chargeRemaining / abs(batteryChargePowerkWH)) * 60 * 60
            let duration = formatter.localizedString(fromTimeInterval: minsUntilEmpty)

            return "Empty \(duration)"
        }
    }
}
