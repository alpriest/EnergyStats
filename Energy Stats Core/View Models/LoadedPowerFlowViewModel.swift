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

public class LoadedPowerFlowViewModel: Equatable, ObservableObject {
    public let solar: Double
    public let solarStrings: [StringPower]
    public let home: Double
    public let grid: Double
    @Published public var todaysGeneration: GenerationViewModel?
    @Published public var earnings: EnergyStatsFinancialModel?
    public let inverterTemperatures: InverterTemperatures?
    @Published public var homeTotal: Double?
    @Published public var gridImportTotal: Double?
    @Published public var gridExportTotal: Double?
    private let batteryViewModel: BatteryViewModel
    public let ct2: Double
    @Published public var deviceState: DeviceState = .unknown
    public let faults: [String]
    private let currentDevice: Device
    private let network: Networking
    private let configManager: ConfigManaging

    public init(solar: Double,
                solarStrings: [StringPower],
                battery: BatteryViewModel,
                home: Double,
                grid: Double,
                inverterTemperatures: InverterTemperatures?,
                ct2: Double,
                faults: [String],
                currentDevice: Device,
                network: Networking,
                configManager: ConfigManaging)
    {
        self.solar = solar
        self.solarStrings = solarStrings
        self.batteryViewModel = battery
        self.home = home
        self.grid = grid
        self.inverterTemperatures = inverterTemperatures
        self.ct2 = ct2
        self.faults = faults
        self.currentDevice = currentDevice
        self.network = network
        self.configManager = configManager

        self.loadDeviceStatus()
        self.loadTotals()
        self.loadGeneration()
    }

    private func loadDeviceStatus() {
        Task {
            let deviceState = try DeviceState(rawValue: await self.network.fetchDevice(deviceSN: self.currentDevice.deviceSN).status) ?? DeviceState.offline

            await MainActor.run {
                self.deviceState = deviceState
            }
        }
    }

    private func loadTotals() {
        guard self.configManager.showHomeTotalOnPowerFlow || self.configManager.showGridTotalsOnPowerFlow || self.configManager.showFinancialEarnings else { return }

        Task {
            let totals = try TotalsViewModel(reports: await self.loadReportData(self.currentDevice))

            await MainActor.run {
                self.earnings = EnergyStatsFinancialModel(totalsViewModel: totals, config: self.configManager)
                self.homeTotal = totals.home
                self.gridImportTotal = totals.gridImport
                self.gridExportTotal = totals.gridExport
            }
        }
    }

    private func loadReportData(_ currentDevice: Device) async throws -> [OpenReportResponse] {
        var reportVariables = [ReportVariable.loads, .feedIn, .gridConsumption]
        if currentDevice.hasBattery {
            reportVariables.append(contentsOf: [.chargeEnergyToTal, .dischargeEnergyToTal])
        }

        return try await self.network.fetchReport(deviceSN: currentDevice.deviceSN,
                                                  variables: reportVariables,
                                                  queryDate: .now(),
                                                  reportType: .month)
    }

    private func loadGeneration() {
        guard self.configManager.showTotalYieldOnPowerFlow else { return }

        Task {
            let generation = try GenerationViewModel(
                response: await self.loadHistoryData(self.currentDevice),
                includeCT2: self.configManager.shouldCombineCT2WithPVPower,
                shouldInvertCT2: self.configManager.shouldInvertCT2
            )

            await MainActor.run {
                self.todaysGeneration = generation
            }
        }
    }

    private func loadHistoryData(_ currentDevice: Device) async throws -> OpenHistoryResponse {
        let start = Calendar.current.startOfDay(for: Date())
        return try await self.network.fetchHistory(deviceSN: currentDevice.deviceSN, variables: ["pvPower", "meterPower2"], start: start, end: start.addingTimeInterval(86400))
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
                                 inverterTemperatures: InverterTemperatures(ambient: 0.0, inverter: 0.0),
                                 ct2: 0,
                                 faults: [],
                                 currentDevice: Device.preview(),
                                 network: DemoNetworking(),
                                 configManager: ConfigManager.preview())
    }

    static func any(battery: BatteryViewModel = .any()) -> LoadedPowerFlowViewModel {
        .init(solar: 3.0,
              solarStrings: [StringPower(name: "PV1", amount: 2.5), StringPower(name: "PV2", amount: 0.5)],
              battery: battery,
              home: 1.5,
              grid: 0.71,
              inverterTemperatures: InverterTemperatures(ambient: 4.0, inverter: 9.0),
              ct2: 2.5,
              faults: [],
              currentDevice: .preview(),
              network: DemoNetworking(),
              configManager: ConfigManager.preview())
    }
}

public extension Device {
    static func preview() -> Device {
        Device(deviceSN: "", stationName: "", stationID: "", battery: nil, moduleSN: "", deviceType: "", hasPV: true, hasBattery: true)
    }
}
