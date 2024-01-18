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
    private let network: FoxESSNetworking
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
        case loaded(HomePowerFlowViewModel)
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

    init(_ network: FoxESSNetworking, configManager: ConfigManaging, userManager: UserManager) {
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
            let currentDeviceSN = currentDevice.deviceSN

            if case .failed = self.state {
                state = .unloaded
            }

            await MainActor.run { self.updateState = "Updating..." }

            var rawVariables = [configManager.variables.named("feedinPower"),
                                self.configManager.variables.named("gridConsumptionPower"),
                                self.configManager.variables.named("loadsPower"),
                                self.configManager.variables.named("generationPower"),
                                self.configManager.variables.named("pvPower"),
                                self.configManager.variables.named("meterPower2")]

            var reportVariables = [ReportVariable.loads, .feedIn, .gridConsumption]
            if self.configManager.hasBattery {
                reportVariables.append(contentsOf: [.chargeEnergyToTal, .dischargeEnergyToTal])
            }

            let reportResponse = try await self.network.openapi_fetchReport(deviceSN: currentDeviceSN,
                                                                            variables: reportVariables,
                                                                            queryDate: .now(),
                                                                            reportType: .month)
            let totals = TotalsViewModel(reports: reportResponse)

            if self.configManager.appSettingsPublisher.value.showInverterTemperature {
                rawVariables.append(contentsOf: [
                    self.configManager.variables.named("ambientTemperation"),
                    self.configManager.variables.named("invTemperation")
                ])
            }

            let real = try await self.network.openapi_fetchRealData(
                deviceSN: currentDeviceSN,
                variables: [
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
                    "batTemperature",
                    "ResidualEnergy"
                ]
            )
            let currentValues = RealQueryResponseMapper.mapCurrentValues(device: currentDevice, response: real)
            let currentViewModel = CurrentStatusCalculator(status: currentValues,
                                                           shouldInvertCT2: self.configManager.shouldInvertCT2,
                                                           shouldCombineCT2WithPVPower: self.configManager.shouldCombineCT2WithPVPower)

            let battery: BatteryViewModel
            if self.configManager.currentDevice.value?.hasBattery == true {
                battery = .init(
                    from: BatteryResponse(
                        power: real.datas.currentValue(for: "batChargePower") - (0 - real.datas.currentValue(for: "batDischargePower")),
                        soc: Int(real.datas.currentValue(for: "SoC")),
                        residual: real.datas.currentValue(for: "ResidualEnergy") * 10.0,
                        temperature: real.datas.currentValue(for: "batTemperature")
                    )
                )
            } else {
                battery = .noBattery
            }

            let start = Calendar.current.startOfDay(for: Date())
            let history = try await network.openapi_fetchHistory(deviceSN: currentDeviceSN, variables: ["pvPower", "meterPower2"], start: start, end: start.addingTimeInterval(86400))

            let summary = HomePowerFlowViewModel(
                solar: currentViewModel.currentSolarPower,
                battery: battery,
                home: currentViewModel.currentHomeConsumption,
                grid: currentViewModel.currentGrid,
                todaysGeneration: GenerationViewModel(response: history),
                earnings: EnergyStatsFinancialModel(totalsViewModel: totals, config: self.configManager, currencySymbol: self.configManager.currencySymbol),
                inverterTemperatures: currentViewModel.currentTemperatures,
                homeTotal: totals.home,
                gridImportTotal: totals.gridImport,
                gridExportTotal: totals.gridExport,
                ct2: currentViewModel.currentCT2
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
