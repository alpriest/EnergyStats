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
    private var latestAppTheme: AppTheme
    private var hasRefreshedFirmware = false

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

    init(_ network: Networking, configManager: ConfigManaging, userManager: UserManager) {
        self.network = network
        self.configManager = configManager
        self.userManager = userManager
        self.latestAppTheme = configManager.appTheme.value

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
            if self.hasRefreshedFirmware == false {
                Task {
                    try await self.configManager.refreshFirmwareVersions()
                    self.hasRefreshedFirmware = true
                }
            }
        }
    }

    @MainActor
    func timerFired() async {
        guard self.timer.isTicking == false else { return }

        self.timer.stop()

        await self.loadData()
        await self.startTimer()

        self.addDeviceChangeObserver()
    }

    func addDeviceChangeObserver() {
        guard self.currentDeviceCancellable == nil else { return }

        self.currentDeviceCancellable = self.configManager.currentDevice.sink { device in
            guard device != nil else { return }

            Task {
                await self.timerFired()
            }
        }
    }

    func addThemeChangeObserver() {
        guard self.themeChangeCancellable == nil else { return }

        self.themeChangeCancellable = self.configManager.appTheme.sink { theme in
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
            await self.network.ensureHasToken()

            var rawVariables = [configManager.variables.named("feedinPower"),
                                self.configManager.variables.named("gridConsumptionPower"),
                                self.configManager.variables.named("loadsPower"),
                                self.configManager.variables.named("generationPower"),
                                self.configManager.variables.named("pvPower"),
                                self.configManager.variables.named("meterPower2")]

            var reportVariables = [ReportVariable.loads, .feedIn, .gridConsumption]
            if currentDevice.hasBattery {
                reportVariables.append(contentsOf: [.chargeEnergyToTal, .dischargeEnergyToTal])
            }

            let totals = try await self.network.fetchReport(deviceID: currentDevice.deviceID,
                                                            variables: reportVariables,
                                                            queryDate: .now(),
                                                            reportType: .month)
            let earnings = try await self.network.fetchEarnings(deviceID: currentDevice.deviceID)
            self.configManager.currencySymbol = earnings.currencySymbol
            let totalsViewModel = TotalsViewModel(reports: totals)

            if self.configManager.appTheme.value.showInverterTemperature {
                rawVariables.append(contentsOf: [
                    self.configManager.variables.named("ambientTemperation"),
                    self.configManager.variables.named("invTemperation")
                ])
            }

            let raws = try await self.network.fetchRaw(deviceID: currentDevice.deviceID, variables: rawVariables.compactMap { $0 }, queryDate: .now())
            let currentViewModel = CurrentStatusCalculator(device: currentDevice,
                                                           raws: raws,
                                                           shouldInvertCT2: self.configManager.shouldInvertCT2,
                                                           shouldCombineCT2WithPVPower: self.configManager.shouldCombineCT2WithPVPower)
            var battery: BatteryViewModel = .noBattery
            if currentDevice.hasBattery {
                do {
                    let response = try await self.network.fetchBattery(deviceID: currentDevice.deviceID)
                    battery = BatteryViewModel(from: response)
                } catch {
                    battery = BatteryViewModel(error: error)
                }
            }

            let summary = HomePowerFlowViewModel(
                solar: currentViewModel.currentSolarPower,
                battery: battery,
                home: currentViewModel.currentHomeConsumption,
                grid: currentViewModel.currentGrid,
                todaysGeneration: earnings.today.generation,
                earnings: EarningsViewModel(response: earnings, energyStatsFinancialModel: EnergyStatsFinancialModel(totalsViewModel: totalsViewModel, config: self.configManager, currencySymbol: self.configManager.currencySymbol)),
                inverterTemperatures: currentViewModel.currentTemperatures,
                homeTotal: totalsViewModel.home,
                gridImportTotal: totalsViewModel.gridImport,
                gridExportTotal: totalsViewModel.gridExport,
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
            try await Task.sleep(nanoseconds: 1_000_000_000)
        } catch {}
    }
}
