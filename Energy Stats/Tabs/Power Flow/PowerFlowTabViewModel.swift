//
//  PowerFlowViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Combine
import Energy_Stats_Core
import Foundation
import UIKit

class PowerFlowTabViewModel: ObservableObject {
    private let network: Networking
    private(set) var configManager: ConfigManaging
    private let userManager: UserManager
    private let timer = CountdownTimer()
    @MainActor @Published private(set) var lastUpdated = Date()
    @MainActor @Published private(set) var updateState: String = "Updating..."
    @MainActor @Published private(set) var state: State = .unloaded
    private(set) var isLoading = false
    private var totalTicks = 60
    private var currentDeviceCancellable: AnyCancellable?
    private var themeChangeCancellable: AnyCancellable?
    private var latestAppTheme: AppSettings

    enum State: Equatable {
        case unloaded
        case loaded(LoadedPowerFlowViewModel)
        case failed(Error?, String)

        static func ==(lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.unloaded, .unloaded):
                return true
            case (.loaded, .loaded):
                return true
            case (.failed, .failed):
                return true
            default:
                return false
            }
        }
    }

    init(_ network: Networking, configManager: ConfigManaging, userManager: UserManager) {
        self.network = network
        self.configManager = configManager
        self.userManager = userManager
        self.latestAppTheme = configManager.appSettingsPublisher.value

        NotificationCenter.default.addObserver(self, selector: #selector(self.willResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func startTimer() async {
        await self.timer.start(totalTicks: self.totalTicks) { ticksRemaining in
            Task { @MainActor in
                self.updateState = String(key: .nextUpdateIn) + " \(PreciseDateTimeFormatter.localizedString(from: ticksRemaining))"
            }
        } onCompletion: {
            Task {
                await self.timerFired()
            }
        }
    }

    func viewAppeared() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard self.userManager.isLoggedIn else { return }

            if self.timer.isTicking == false {
                await self.timerFired()
            }
            self.addDeviceChangeObserver()
            self.addThemeChangeObserver()
        }
    }

    @MainActor
    func timerFired() async {
        self.timer.stop()
        await self.loadData()
        await self.startTimer()
    }

    func addDeviceChangeObserver() {
        guard self.currentDeviceCancellable == nil else { return }

        self.currentDeviceCancellable = self.configManager.currentDevice
            .removeDuplicates()
            .sink { device in
                guard device != nil else { return }

                Task {
                    await self.timerFired()
                }
            }
    }

    func addThemeChangeObserver() {
        guard self.themeChangeCancellable == nil else { return }

        self.themeChangeCancellable = self.configManager.appSettingsPublisher.sink { theme in
            if self.latestAppTheme.showInverterTemperature != theme.showInverterTemperature ||
                self.latestAppTheme.shouldInvertCT2 != theme.shouldInvertCT2 ||
                self.latestAppTheme.shouldCombineCT2WithPVPower != theme.shouldCombineCT2WithPVPower
            {
                self.latestAppTheme = theme
                Task { await self.loadData() }
            }
        }
    }

    func stopTimer() async {
        await self.timer.stop()
    }

    @MainActor
    func loadData() async {
        guard self.isLoading == false else { return }

        self.isLoading = true
        defer { isLoading = false }

        do {
            if self.configManager.currentDevice.value == nil {
                try await self.configManager.fetchDevices()
            }

            guard let currentDevice = configManager.currentDevice.value else {
                self.state = .failed(nil, "No devices found. Please logout and try logging in again.")
                return
            }

            if case .failed = self.state {
                state = .unloaded
            }

            await MainActor.run { self.updateState = "Updating..." }

            let deviceState = try await loadDeviceStatus(currentDevice)
            let totals = try await loadTotals(currentDevice)
            let real = try await loadRealData(currentDevice, config: configManager)
            let generation = try await self.loadGeneration(currentDevice)

            let currentViewModel = CurrentStatusCalculator(device: currentDevice,
                                                           response: real,
                                                           config: configManager)

            let battery = self.makeBatteryViewModel(currentDevice, real)

            let summary = LoadedPowerFlowViewModel(
                solar: currentViewModel.currentSolarPower,
                solarStrings: currentViewModel.currentSolarStringsPower,
                battery: battery,
                home: currentViewModel.currentHomeConsumption,
                grid: currentViewModel.currentGrid,
                todaysGeneration: generation,
                earnings: EnergyStatsFinancialModel(totalsViewModel: totals, config: self.configManager),
                inverterTemperatures: currentViewModel.currentTemperatures,
                homeTotal: totals.home,
                gridImportTotal: totals.gridImport,
                gridExportTotal: totals.gridExport,
                ct2: currentViewModel.currentCT2,
                deviceState: deviceState,
                faults: currentViewModel.currentFaults
            )

            self.state = .loaded(.empty()) // refreshes the marching ants line speed
            try await Task.sleep(nanoseconds: 1000)
            self.state = .loaded(summary)
            self.lastUpdated = currentViewModel.lastUpdate
            self.calculateTicks(historicalViewModel: currentViewModel)
            self.updateState = " "
        } catch {
            await self.stopTimer()
            self.state = .failed(error, error.localizedDescription)
        }
    }

    private func makeBatteryViewModel(_ currentDevice: Device, _ real: OpenQueryResponse) -> BatteryViewModel {
        if self.configManager.currentDevice.value?.hasBattery == true {
            let chargePower = real.datas.currentDouble(for: "batChargePower")
            let dischargePower = real.datas.currentDouble(for: "batDischargePower")
            let power = chargePower > 0 ? chargePower : -dischargePower

            return BatteryViewModel(
                power: power,
                soc: Int(real.datas.SoC()),
                residual: real.datas.currentDouble(for: "ResidualEnergy") * 10.0,
                temperature: real.datas.currentDouble(for: "batTemperature")
            )
        } else {
            return BatteryViewModel.noBattery
        }
    }

    private func loadGeneration(_ currentDevice: Device) async throws -> GenerationViewModel {
        try GenerationViewModel(response: await self.loadHistoryData(currentDevice), includeCT2: self.configManager.shouldCombineCT2WithPVPower, shouldInvertCT2: self.configManager.shouldInvertCT2)
    }

    private func loadHistoryData(_ currentDevice: Device) async throws -> OpenHistoryResponse {
        let start = Calendar.current.startOfDay(for: Date())
        return try await self.network.fetchHistory(deviceSN: currentDevice.deviceSN, variables: ["pvPower", "meterPower2"], start: start, end: start.addingTimeInterval(86400))
    }

    private func loadDeviceStatus(_ currentDevice: Device) async throws -> DeviceState {
        try DeviceState(rawValue: await self.network.fetchDevice(deviceSN: currentDevice.deviceSN).status) ?? DeviceState.offline
    }

    private func loadTotals(_ currentDevice: Device) async throws -> TotalsViewModel {
        try TotalsViewModel(reports: await self.loadReportData(currentDevice))
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

    private func loadRealData(_ currentDevice: Device, config: ConfigManaging) async throws -> OpenQueryResponse {
        var variables = [
            "feedinPower",
            "gridConsumptionPower",
            "loadsPower",
            "generationPower",
            "pvPower",
            "meterPower2",
            "ambientTemperation",
            "invTemperation",
            "batChargePower",
            "batDischargePower",
            "SoC",
            "SoC_1",
            "batTemperature",
            "ResidualEnergy",
            "epsPower",
            "currentFault"
        ]

        if config.powerFlowStrings.enabled {
            variables.append(contentsOf: config.powerFlowStrings.variableNames())
        }

        return try await self.network.fetchRealData(
            deviceSN: currentDevice.deviceSN,
            variables: variables
        )
    }

    func calculateTicks(historicalViewModel: CurrentStatusCalculator) {
        switch self.configManager.refreshFrequency {
        case .ONE_MINUTE:
            self.totalTicks = 60
        case .FIVE_MINUTES:
            self.totalTicks = 300
        case .AUTO:
            if self.configManager.isDemoUser {
                self.totalTicks = 300
            } else {
                self.totalTicks = Int(300 - (Date().timeIntervalSince(historicalViewModel.lastUpdate)) + 10)
                if self.totalTicks <= 0 {
                    self.totalTicks = 300
                }
            }
        }
    }

    @objc
    func didBecomeActiveNotification() {
        Task { await self.timerFired() }
    }

    @objc
    func willResignActiveNotification() {
        Task { await self.stopTimer() }
    }

    func sleep() async {
        do {
            try await Task.sleep(nanoseconds: 1000000000)
        } catch {}
    }
}
