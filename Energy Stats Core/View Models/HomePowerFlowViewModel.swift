//
//  PowerFlowViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import Foundation

public struct InverterTemperatures {
    public let ambient: Double
    public let inverter: Double

    public init(ambient: Double, inverter: Double) {
        self.ambient = ambient
        self.inverter = inverter
    }
}

public struct HomePowerFlowViewModel: Equatable {
    public let solar: Double
    public let battery: Double
    public let home: Double
    public let grid: Double
    public let batteryStateOfCharge: Double
    public let hasBattery: Bool
    public let batteryTemperature: Double
    public let todaysGeneration: Double
    public let earnings: String
    public let batteryResidual: Int
    public let inverterTemperatures: InverterTemperatures

    public init(solar: Double, battery: Double, home: Double, grid: Double, batteryStateOfCharge: Double, hasBattery: Bool, batteryTemperature: Double, batteryResidual: Int, todaysGeneration: Double, earnings: String, inverterTemperatures: InverterTemperatures) {
        self.solar = solar
        self.battery = battery
        self.home = home
        self.grid = grid
        self.batteryStateOfCharge = batteryStateOfCharge
        self.hasBattery = hasBattery
        self.batteryTemperature = batteryTemperature
        self.todaysGeneration = todaysGeneration
        self.earnings = earnings
        self.batteryResidual = batteryResidual
        self.inverterTemperatures = inverterTemperatures
    }

    public static func ==(lhs: HomePowerFlowViewModel, rhs: HomePowerFlowViewModel) -> Bool {
        lhs.solar == rhs.solar &&
            lhs.battery == rhs.battery &&
            lhs.home == rhs.home &&
            lhs.grid == rhs.grid &&
            lhs.batteryStateOfCharge == rhs.batteryStateOfCharge &&
            lhs.hasBattery == rhs.hasBattery &&
            lhs.batteryTemperature == rhs.batteryTemperature &&
            lhs.batteryResidual == rhs.batteryResidual
    }
}

public extension HomePowerFlowViewModel {
    static func empty() -> Self {
        .init(solar: 0,
              battery: 0,
              home: 0,
              grid: 0,
              batteryStateOfCharge: 0,
              hasBattery: false,
              batteryTemperature: 0.0,
              batteryResidual: 0,
              todaysGeneration: 0.0,
              earnings: "",
              inverterTemperatures: InverterTemperatures(ambient: 0.0, inverter: 0.0))
    }
}
