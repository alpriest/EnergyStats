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
import os

struct UpdateState {
    let text: String
    let accessibilityText: String

    init(text: String, accessibilityText: String) {
        self.text = text
        self.accessibilityText = accessibilityText
    }

    init(_ text: String) {
        self.init(text: text, accessibilityText: text)
    }
}

class PowerFlowTabViewModel: ObservableObject, VisibilityTracking {
    private let network: Networking
    private(set) var configManager: ConfigManaging
    private let userManager: UserManager
    private let timer = CountdownTimer()
    @MainActor @Published private(set) var lastUpdated = Date()
    @MainActor @Published private(set) var updateState: UpdateState = .init("Updating...")
    @MainActor @Published private(set) var state: State = .unloaded
    private(set) var isLoading = false
    private var totalTicks = 60
    private var currentDeviceCancellable: AnyCancellable?
    private var themeChangeCancellable: AnyCancellable?
    private var latestAppTheme: AppSettings
    private var latestDeviceSN: String?
    var visible: Bool = false
    private var currentStatusCalculator: CurrentStatusCalculator?
    private var loadLock = OSAllocatedUnfairLock()
    @Published public var earnings: EnergyStatsFinancialModel?

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
        
        var isLoaded: Bool {
            if case .loaded = self {
                return true
            } else {
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
        self.timer.start(totalTicks: self.totalTicks) { ticksRemaining in
            Task { @MainActor in
                self.updateState = UpdateState(
                    text: String(key: .nextUpdateIn) + " \(PreciseDateTimeFormatter.localizedString(from: ticksRemaining))",
                    accessibilityText: String(key: .nextUpdateIn) + " \(PreciseDateTimeFormatter.localizedAccessibilityString(from: ticksRemaining))"
                )
            }
        } onCompletion: {
            Task {
                await self.timerFired()
            }
        }
    }

    @MainActor
    func viewAppeared() async {
        guard self.userManager.isLoggedIn == true else { return }

        if self.timer.isTicking == false {
            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
            await self.timerFired()
        }
        self.addDeviceChangeObserver()
        self.addThemeChangeObserver()
    }

    @MainActor
    func timerFired() async {
        self.timer.stop()
        await self.loadData()
        if state.isLoaded {
            await self.startTimer()
        }
    }

    func addDeviceChangeObserver() {
        guard self.currentDeviceCancellable == nil else { return }

        self.currentDeviceCancellable = self.configManager.currentDevice
            .removeDuplicates()
            .drop { _ in self.latestDeviceSN == nil }
            .drop { self.latestDeviceSN == $0?.deviceSN }
            .sink { _ in
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
        self.timer.stop()
    }

    @MainActor
    func loadData() async {
        loadLock.withLock {
            guard self.isLoading == false else { return }
            self.isLoading = true
        }

        defer { isLoading = false }

        do {
            if self.configManager.currentDevice.value == nil {
                try await self.configManager.fetchDevices()
            }

            guard let currentDevice = configManager.currentDevice.value else {
                self.state = .failed(nil, "No devices found. Please logout and try logging in again.")
                return
            }

            self.latestDeviceSN = currentDevice.deviceSN

            if case .failed = self.state {
                state = .unloaded
            }

            await MainActor.run { self.updateState = UpdateState("Updating...") }

            let real = try await loadRealData(currentDevice, config: configManager)
            let currentStatusCalculator = CurrentStatusCalculator(device: currentDevice,
                                                                  response: real,
                                                                  config: configManager)
            self.currentStatusCalculator = currentStatusCalculator

            let battery = BatteryViewModel.make(currentDevice: currentDevice, real: real)
            if battery.hasBattery, let batterySettings = try? await network.fetchBatterySettings(deviceSN: currentDevice.deviceSN) {
                self.configManager.minSOC = batterySettings.minSocOnGridPercent
            }

            let (totals, financialModel, generation) = try await self.loadTotals(for: currentDevice)
            
            let summary = LoadedPowerFlowViewModel(
                currentValuesPublisher: currentStatusCalculator.currentValuesPublisher,
                battery: battery,
                currentDevice: currentDevice,
                network: self.network,
                configManager: self.configManager,
                totals: totals,
                financialModel: financialModel,
                generation: generation
            )

            if Task.isCancelled { return }

            self.state = .loaded(summary)
            self.lastUpdated = currentStatusCalculator.lastUpdate
            self.calculateTicks(historicalViewModel: currentStatusCalculator)
            self.updateState = UpdateState(" ")
        } catch {
            await self.stopTimer()
            self.state = .failed(error, error.localizedDescription)
        }
    }

    private func loadTotals(for device: Device) async throws -> (TotalsViewModel?, EnergyStatsFinancialModel?, GenerationViewModel?) {
        guard self.configManager.showHomeTotalOnPowerFlow ||
            self.configManager.showGridTotalsOnPowerFlow ||
            self.configManager.showFinancialEarnings ||
            self.configManager.showTotalYieldOnPowerFlow else { return (nil, nil, nil) }

        let generation = try await self.loadGeneration(for: device)
        let totals = try TotalsViewModel(reports: await self.loadReportData(device), generationViewModel: generation)
        generation?.updatePvTotal(totals.solar)
        let financialModel = EnergyStatsFinancialModel(totalsViewModel: totals, config: self.configManager)

        if Task.isCancelled { return (nil, nil, nil) }

        return (totals, financialModel, generation)
    }

    private func loadGeneration(for device: Device) async throws -> GenerationViewModel? {
        guard self.configManager.showTotalYieldOnPowerFlow ||
            self.configManager.powerFlowStrings.enabled ||
            self.configManager.ct2DisplayMode != .hidden ||
            self.configManager.shouldCombineCT2WithPVPower
        else { return nil }

        return try await GenerationViewModelBuilder.build(
            configManager: self.configManager,
            network: self.network,
            device: device
        )
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
            "batTemperature_1",
            "batTemperature_2",
            "ResidualEnergy"
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
        if self.visible {
            Task { await self.timerFired() }
        }
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
