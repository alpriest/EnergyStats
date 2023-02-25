//
//  PowerFlowViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import Foundation

struct HomePowerFlowViewModel: Equatable {
    let configManager: ConfigManager
    let solar: Double
    let battery: Double
    let home: Double
    let grid: Double
    let batteryStateOfCharge: Double
    let hasBattery: Bool

    static func ==(lhs: HomePowerFlowViewModel, rhs: HomePowerFlowViewModel) -> Bool {
        lhs.solar == rhs.solar &&
        lhs.battery == rhs.battery &&
        lhs.home == rhs.home &&
        lhs.grid == rhs.grid &&
        lhs.batteryStateOfCharge == rhs.batteryStateOfCharge &&
        lhs.hasBattery == rhs.hasBattery
    }
}

extension HomePowerFlowViewModel {
    static func empty(configManager: ConfigManager) -> Self {
        .init(configManager: configManager, solar: 0, battery: 0, home: 0, grid: 0, batteryStateOfCharge: 0, hasBattery: false)
    }
}
