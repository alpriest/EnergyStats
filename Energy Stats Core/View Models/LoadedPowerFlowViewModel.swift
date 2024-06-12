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
    case unknown = 99
}

public class LoadedPowerFlowViewModel: Equatable, Observable {
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
    @Published public var deviceState: DeviceState = .unknown
    public let faults: [String]
    private let currentDevice: Device
    private let network: Networking

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
                faults: [String],
                currentDevice: Device,
                network: Networking)
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
        self.faults = faults
        self.currentDevice = currentDevice
        self.network = network

        self.loadDeviceStatus()
    }

    private func loadDeviceStatus() {
        Task {
            let deviceState = try DeviceState(rawValue: await self.network.fetchDevice(deviceSN: self.currentDevice.deviceSN).status) ?? DeviceState.offline

            await MainActor.run {
                self.deviceState = deviceState
            }
        }
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
    static func empty() -> LoadedPowerFlowViewModel {
        LoadedPowerFlowViewModel(solar: 0,
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
                                 faults: [],
                                 currentDevice: Device.preview(),
                                 network: DemoNetworking())
    }

    static func any(battery: BatteryViewModel = .any()) -> LoadedPowerFlowViewModel {
        .init(solar: 3.0,
              solarStrings: [StringPower(name: "PV1", amount: 2.5), StringPower(name: "PV2", amount: 0.5)],
              battery: battery,
              home: 1.5,
              grid: 0.71,
              todaysGeneration: GenerationViewModel(response: OpenHistoryResponse(deviceSN: "abc123", datas: []), includeCT2: false, shouldInvertCT2: false),
              earnings: .any(),
              inverterTemperatures: InverterTemperatures(ambient: 4.0, inverter: 9.0),
              homeTotal: 1.0,
              gridImportTotal: 12.0,
              gridExportTotal: 2.4,
              ct2: 2.5,
              faults: [],
              currentDevice: .preview(),
              network: DemoNetworking())
    }
}

public extension Device {
    static func preview() -> Device {
        Device(deviceSN: "", stationName: "", stationID: "", battery: nil, moduleSN: "", deviceType: "", hasPV: true, hasBattery: true)
    }
}
