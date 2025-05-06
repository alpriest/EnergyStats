//
//  PowerFlowViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import Combine
import Foundation

public struct InverterTemperatures: Sendable {
    public let ambient: Double
    public let inverter: Double

    public init(ambient: Double, inverter: Double) {
        self.ambient = ambient
        self.inverter = inverter
    }
}

public enum DeviceState: Int {
    case online = 1
    case fault = 2
    case offline = 3
    case unknown = 99
}

public class LoadedPowerFlowViewModel: Equatable, ObservableObject {
    @Published public var solar: Double = 0
    @Published public var displayStrings: [StringPower] = []
    @Published public var home: Double = 0
    @Published public var grid: Double = 0
    @Published public var todaysGeneration: GenerationViewModel?
    @Published public var earnings: EnergyStatsFinancialModel?
    @Published public var inverterTemperatures: InverterTemperatures?
    @Published public var homeTotal: Double?
    @Published public var gridImportTotal: Double?
    @Published public var gridExportTotal: Double?
    private let batteryViewModel: BatteryViewModel
    @Published public var ct2: Double = 0
    @Published public var deviceState: DeviceState = .unknown
    @Published public var faults: [String] = []
    @Published public var showCT2: Bool = false
    private let currentDevice: Device
    private let network: Networking
    private let configManager: ConfigManaging
    @Published private var solarStrings: [StringPower] = []
    private var cancellables = Set<AnyCancellable>()

    public init(currentValuesPublisher: AnyPublisher<CurrentValues, Never>,
                battery: BatteryViewModel,
                currentDevice: Device,
                network: Networking,
                configManager: ConfigManaging)
    {
        self.batteryViewModel = battery
        self.currentDevice = currentDevice
        self.network = network
        self.configManager = configManager

        currentValuesPublisher
            .combineLatest(configManager.appSettingsPublisher)
            .receive(on: RunLoop.main)
            .sink { [weak self] values, appSettings in
                self?.solar = values.solarPower
                self?.solarStrings = values.solarStringsPower
                self?.home = values.homeConsumption
                self?.grid = values.grid
                self?.ct2 = values.ct2
                self?.inverterTemperatures = values.temperatures

                self?.updateDisplayStrings(appSettings)
            }
            .store(in: &self.cancellables)

        self.loadDeviceStatus()
        self.loadTotals()
    }

    private func updateDisplayStrings(_ settings: AppSettings) {
        var displayStrings: [StringPower] = []

        if settings.ct2DisplayMode == .asPowerString {
            displayStrings.append(StringPower(name: "CT2", amount: self.ct2))
        }

        if settings.powerFlowStrings.enabled {
            displayStrings.append(contentsOf: self.solarStrings)
        }

        self.displayStrings = displayStrings
    }

    private func loadDeviceStatus() {
        Task {
            let deviceState = try DeviceState(rawValue: await self.network.fetchDevice(deviceSN: self.currentDevice.deviceSN).status) ?? DeviceState.offline
            let faults: [String]

            switch deviceState {
            case .online:
                faults = []
            case .fault:
                faults = try await self.loadCurrentFaults()
            case .offline:
                NotificationCenter.default.post(name: .deviceIsOffline, object: nil)
                faults = try await self.loadCurrentFaults()
            case .unknown:
                faults = []
            }

            if Task.isCancelled { return }

            await MainActor.run {
                self.faults = faults
                self.deviceState = deviceState
            }
        }
    }

    private func loadCurrentFaults() async throws -> [String] {
        guard let result = try? await self.network.fetchRealData(
            deviceSN: currentDevice.deviceSN,
            variables: ["currentFault"]
        ), let currentFaults = result.datas.currentString(for: "currentFault")
        else { return [] }

        return currentFaults.split(separator: ",").map { String($0) }
    }

    private func loadTotals() {
        guard self.configManager.showHomeTotalOnPowerFlow ||
            self.configManager.showGridTotalsOnPowerFlow ||
            self.configManager.showFinancialEarnings ||
            self.configManager.showTotalYieldOnPowerFlow else { return }

        Task {
            let totals = try TotalsViewModel(reports: await self.loadReportData(self.currentDevice))

            if Task.isCancelled { return }

            await MainActor.run {
                self.earnings = EnergyStatsFinancialModel(totalsViewModel: totals, config: self.configManager)
                self.homeTotal = totals.home
                self.gridImportTotal = totals.gridImport
                self.gridExportTotal = totals.gridExport
            }

            self.loadGeneration(using: totals)
        }
    }

    private func loadReportData(_ currentDevice: Device) async throws -> [OpenReportResponse] {
        var reportVariables = [ReportVariable.loads, .feedIn, .gridConsumption, .pvEnergyTotal]
        if currentDevice.hasBattery {
            reportVariables.append(contentsOf: [.chargeEnergyToTal, .dischargeEnergyToTal])
        }

        return try await self.network.fetchReport(deviceSN: currentDevice.deviceSN,
                                                  variables: reportVariables,
                                                  queryDate: .now(),
                                                  reportType: .month)
    }

    private func loadGeneration(using totals: TotalsViewModel) {
        guard self.configManager.showTotalYieldOnPowerFlow else { return }

        Task {
            let generation = try GenerationViewModel(
                pvTotal: totals.solar,
                response: await self.loadHistoryData(self.currentDevice),
                includeCT2: self.configManager.shouldCombineCT2WithPVPower,
                shouldInvertCT2: self.configManager.shouldInvertCT2
            )

            if Task.isCancelled { return }

            await MainActor.run {
                self.todaysGeneration = generation
            }
        }
    }

    private func loadHistoryData(_ currentDevice: Device) async throws -> OpenHistoryResponse {
        let start = Calendar.current.startOfDay(for: Date())
        return try await self.network.fetchHistory(deviceSN: currentDevice.deviceSN, variables: ["meterPower2", "pv1Power", "pv2Power", "pv3Power", "pv4Power", "pv5Power", "pv6Power"], start: start, end: start.addingTimeInterval(86400))
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

    public var batteryTemperatures: BatteryTemperatures {
        self.batteryViewModel.temperatures
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
}

public extension LoadedPowerFlowViewModel {
    static func empty() -> LoadedPowerFlowViewModel {
        let values = CurrentValues(
            solarPower: 0,
            solarStringsPower: [],
            grid: 0,
            homeConsumption: 0,
            temperatures: InverterTemperatures(ambient: 0, inverter: 0),
            ct2: 0
        )
        return LoadedPowerFlowViewModel(
            currentValuesPublisher: Just(values).eraseToAnyPublisher(),
            battery: BatteryViewModel.noBattery,
            currentDevice: Device.preview(),
            network: DemoNetworking(),
            configManager: ConfigManager.preview()
        )
    }

    static func any(battery: BatteryViewModel = .any(), appSettings: AppSettings = .mock()) -> LoadedPowerFlowViewModel {
        let values = CurrentValues(
            solarPower: 3.0,
            solarStringsPower: [StringPower(name: "PV1", amount: 2.5), StringPower(name: "PV2", amount: 0.5)],
            grid: 0.71,
            homeConsumption: 1.5,
            temperatures: InverterTemperatures(ambient: 4.0, inverter: 9.0),
            ct2: 2.5
        )
        return LoadedPowerFlowViewModel(
            currentValuesPublisher: Just(values).eraseToAnyPublisher(),
            battery: battery,
            currentDevice: .preview(),
            network: DemoNetworking(),
            configManager: ConfigManager.preview(appSettings: appSettings)
        )
    }
}

public extension Device {
    static func preview() -> Device {
        Device(deviceSN: "", stationName: "", stationID: "", battery: nil, moduleSN: "", deviceType: "", hasPV: true, hasBattery: true, productType: nil)
    }
}
