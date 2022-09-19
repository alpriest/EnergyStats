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
    private let minimumSOC: Double

    init(capacitykW: Double, minimumSOC: Double = 0.2) {
        self.capacitykW = capacitykW
        self.minimumSOC = minimumSOC
    }

    var minimumCharge: Double {
        capacitykW * minimumSOC
    }

    func batteryRemaining(batteryChargePowerkWH: Double, batteryStartOfCharge: Double) -> String? {
        let currentEstimatedCharge = capacitykW * batteryStartOfCharge

        if batteryChargePowerkWH > 0 { // battery charging
            if batteryStartOfCharge >= 98.99 { return nil }

            let capacityRemaining = capacitykW - currentEstimatedCharge
            let minsToFullCharge = (capacityRemaining / batteryChargePowerkWH) * 60 * 60
            let duration = formatter.localizedString(fromTimeInterval: minsToFullCharge)

            return "Full \(duration)"
        } else { // battery emptying
            if batteryStartOfCharge <= (minimumSOC * 1.01) { return nil }
            let chargeRemaining = currentEstimatedCharge - minimumCharge
            let minsUntilEmpty = (chargeRemaining / abs(batteryChargePowerkWH)) * 60 * 60
            let duration = formatter.localizedString(fromTimeInterval: minsUntilEmpty)

            return "Empty \(duration)"
        }
    }
}
