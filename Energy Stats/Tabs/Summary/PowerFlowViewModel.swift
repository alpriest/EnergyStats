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
    let hasBattery: Bool

    var batteryExtra: String? {
        let capacity = Config.shared.batteryCapacity.asDouble() ?? 7800
        let minSOC = Config.shared.minSOC.asDouble() ?? 0.2

        return BatteryCapacityCalculator(capacitykW: capacity, minimumSOC: minSOC).batteryRemaining(batteryChargePowerkWH: battery, batteryStateOfCharge: batteryStateOfCharge)
    }
}
