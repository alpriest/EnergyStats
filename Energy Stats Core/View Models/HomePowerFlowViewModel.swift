//
//  PowerFlowViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import Foundation

public struct InverterTemperatures: Sendable {
    public let ambient: Double
    public let inverter: Double

    public init(ambient: Double, inverter: Double) {
        self.ambient = ambient
        self.inverter = inverter
    }
}

public struct HomePowerFlowViewModel: Equatable {
    public let solar: Double
    public let home: Double
    public let grid: Double
    public let todaysGeneration: Double
    public let earnings: EarningsViewModel
    public let inverterTemperatures: InverterTemperatures?
    public let homeTotal: Double
    public let gridImportTotal: Double
    public let gridExportTotal: Double
    private let batteryViewModel: BatteryViewModel
    public let ct2: Double

    public init(solar: Double,
                battery: BatteryViewModel,
                home: Double,
                grid: Double,
                todaysGeneration: Double,
                earnings: EarningsViewModel,
                inverterTemperatures: InverterTemperatures?,
                homeTotal: Double,
                gridImportTotal: Double,
                gridExportTotal: Double,
                ct2: Double)
    {
        self.solar = solar
        self.batteryViewModel = battery
        self.home = home
        self.grid = grid
        self.todaysGeneration = todaysGeneration
        self.earnings = earnings
        self.inverterTemperatures = inverterTemperatures
        self.homeTotal = homeTotal
        self.gridImportTotal = gridImportTotal
        self.gridExportTotal = gridExportTotal
        self.ct2 = ct2
    }

    public static func ==(lhs: HomePowerFlowViewModel, rhs: HomePowerFlowViewModel) -> Bool {
        lhs.solar == rhs.solar &&
            lhs.home == rhs.home &&
            lhs.grid == rhs.grid
    }

    public var batteryStateOfCharge: Double {
        self.batteryViewModel.chargeLevel
    }

    public var hasBattery: Bool {
        self.batteryViewModel.hasBattery
    }

    public var hasBatteryError: Bool {
        self.batteryError != nil
    }

    public var batteryTemperature: Double {
        self.batteryViewModel.temperature
    }

    public var batteryResidual: Int {
        self.batteryViewModel.residual
    }

    public var battery: Double {
        self.batteryViewModel.chargePower
    }

    public var batteryError: Error? {
        self.batteryViewModel.error
    }

    public var showCT2: Bool {
        self.ct2 > 0
    }
}

public extension HomePowerFlowViewModel {
    static func empty() -> Self {
        .init(solar: 0,
              battery: BatteryViewModel.noBattery,
              home: 0,
              grid: 0,
              todaysGeneration: 0.0,
              earnings: .empty(),
              inverterTemperatures: InverterTemperatures(ambient: 0.0, inverter: 0.0),
              homeTotal: 0,
              gridImportTotal: 0,
              gridExportTotal: 0,
              ct2: 0)
    }
}
