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
        let capacity = Config.shared.batteryCapacity.asDouble() ?? 7800
        let minSOC = Config.shared.minSOC.asDouble() ?? 0.2

        return BatteryCalculator(capacitykW: capacity, minimumSOC: minSOC).batteryRemaining(batteryChargePowerkWH: battery, batteryStateOfCharge: batteryStateOfCharge)
    }
}

class BatteryCalculator {
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
            if batteryStateOfCharge <= (minimumSOC * 1.04) { return nil }
            let chargeRemaining = currentEstimatedCharge - minimumCharge
            let minsUntilEmpty = (chargeRemaining / abs(batteryChargePowerkWH * 1000.0)) * 60 * 60
            let duration = formatter.localizedString(fromTimeInterval: minsUntilEmpty)

            return "Empty \(duration)"
        }
    }
}

extension Optional where Wrapped == String {
    func asDouble() -> Double? {
        guard let self = self else { return nil }

        return Double(self)
    }
}
