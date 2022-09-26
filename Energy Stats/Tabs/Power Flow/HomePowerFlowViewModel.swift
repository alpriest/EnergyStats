//
//  PowerFlowViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import Foundation

struct HomePowerFlowViewModel: Equatable {
    let config: Config
    let solar: Double
    let battery: Double
    let home: Double
    let grid: Double
    let batteryStateOfCharge: Double
    let hasBattery: Bool

    var batteryExtra: String? {
        let capacity = config.batteryCapacity.asDouble() ?? 7800
        let minSOC = config.minSOC.asDouble() ?? 0.2

        return BatteryCapacityCalculator(capacitykW: capacity, minimumSOC: minSOC).batteryRemaining(batteryChargePowerkWH: battery, batteryStateOfCharge: batteryStateOfCharge)
    }

    static func ==(lhs: HomePowerFlowViewModel, rhs: HomePowerFlowViewModel) -> Bool {
        lhs.solar == rhs.solar &&
        lhs.battery == rhs.battery &&
        lhs.home == rhs.home &&
        lhs.grid == rhs.grid &&
        lhs.batteryStateOfCharge == rhs.batteryStateOfCharge &&
        lhs.hasBattery == rhs.hasBattery
    }
}
