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

public struct StringPower: Identifiable {
    public let name: String
    public let amount: Double

    public var id: String { self.name }

    public init(name: String, amount: Double) {
        self.name = name
        self.amount = amount
    }

    public func displayName(settings: PowerFlowStringsSettings) -> String {
        switch self.name {
        case "PV1":
            return settings.pv1Name
        case "PV2":
            return settings.pv2Name
        case "PV3":
            return settings.pv3Name
        default:
            return settings.pv4Name
        }
    }
}

public enum DeviceState: Int {
    case online = 1
    case fault = 2
    case offline = 3
}

public struct LoadedPowerFlowViewModel: Equatable {
    public let solar: Double
    public let solarStrings: [StringPower]
    public let home: Double
    public let grid: Double
    public let todaysGeneration: GenerationViewModel
    public let earnings: EnergyStatsFinancialModel
    public let inverterTemperatures: InverterTemperatures?
    public let homeTotal: Double
    public let gridImportTotal: Double
    public let gridExportTotal: Double
    private let batteryViewModel: BatteryViewModel
    public let ct2: Double
    public let deviceState: DeviceState
    public let faults: [String]

    public init(solar: Double,
                solarStrings: [StringPower],
                battery: BatteryViewModel,
                home: Double,
                grid: Double,
                todaysGeneration: GenerationViewModel,
                earnings: EnergyStatsFinancialModel,
                inverterTemperatures: InverterTemperatures?,
                homeTotal: Double,
                gridImportTotal: Double,
                gridExportTotal: Double,
                ct2: Double,
                deviceState: DeviceState,
                faults: [String])
    {
        self.solar = solar
        self.solarStrings = solarStrings
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
        self.deviceState = deviceState
        self.faults = faults
    }

    public static func ==(lhs: LoadedPowerFlowViewModel, rhs: LoadedPowerFlowViewModel) -> Bool {
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

public extension LoadedPowerFlowViewModel {
    static func empty() -> Self {
        .init(solar: 0,
              solarStrings: [],
              battery: BatteryViewModel.noBattery,
              home: 0,
              grid: 0,
              todaysGeneration: GenerationViewModel(response: OpenHistoryResponse(deviceSN: "abc123", datas: []), includeCT2: false, shouldInvertCT2: false),
              earnings: .empty(),
              inverterTemperatures: InverterTemperatures(ambient: 0.0, inverter: 0.0),
              homeTotal: 0,
              gridImportTotal: 0,
              gridExportTotal: 0,
              ct2: 0,
              deviceState: .offline,
              faults: [])
    }
}
