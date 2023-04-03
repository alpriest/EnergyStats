//
//  PowerFlowViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import Foundation

public struct HomePowerFlowViewModel: Equatable {
    public let solar: Double
    public let battery: Double
    public let home: Double
    public let grid: Double
    public let batteryStateOfCharge: Double
    public let hasBattery: Bool
    public let batteryTemperature: Double

    public init(solar: Double, battery: Double, home: Double, grid: Double, batteryStateOfCharge: Double, hasBattery: Bool, batteryTemperature: Double) {
        self.solar = solar
        self.battery = battery
        self.home = home
        self.grid = grid
        self.batteryStateOfCharge = batteryStateOfCharge
        self.hasBattery = hasBattery
        self.batteryTemperature = batteryTemperature
    }

    public static func ==(lhs: HomePowerFlowViewModel, rhs: HomePowerFlowViewModel) -> Bool {
        lhs.solar == rhs.solar &&
            lhs.battery == rhs.battery &&
            lhs.home == rhs.home &&
            lhs.grid == rhs.grid &&
            lhs.batteryStateOfCharge == rhs.batteryStateOfCharge &&
            lhs.hasBattery == rhs.hasBattery &&
            lhs.batteryTemperature == rhs.batteryTemperature
    }
}

extension HomePowerFlowViewModel {
    public static func empty() -> Self {
        .init(solar: 0, battery: 0, home: 0, grid: 0, batteryStateOfCharge: 0, hasBattery: false, batteryTemperature: 15.6)
    }
}
