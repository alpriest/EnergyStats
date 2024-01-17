//
//  ContentViewModel.swift
//  Energy Stats Watch App Watch App
//
//  Created by Alistair Priest on 03/04/2023.
//

import Energy_Stats_Core
import Foundation

class ContentViewModel: ObservableObject {
    @Published var summary: HomePowerFlowViewModel? = nil

    private let network: Networking
    private var configManager: ConfigManager
    private let timer = CountdownTimer()
    @MainActor @Published private(set) var updateState: String = "Updating..."
    private(set) var isLoading = false
    private var totalTicks = 60

    init(_ network: Networking, configManager: ConfigManager) {
        self.network = network
        self.configManager = configManager
    }

    func startTimer() async {
        await self.timer.start(totalTicks: self.totalTicks) { ticksRemaining in
            Task { @MainActor in
                self.updateState = PreciseDateTimeFormatter.localizedString(from: ticksRemaining)
            }
        } onCompletion: {
            Task {
                await self.timerFired()
            }
        }
    }

    func timerFired() async {
        guard self.configManager.currentDevice != nil else {
            await MainActor.run {
                self.updateState = "Please login via the iOS app first."
            }
            return
        }
        guard self.isLoading == false else { return }

        self.isLoading = true
        defer { isLoading = false }

        await self.loadData()
        await self.startTimer()
    }

    func stopTimer() async {
        await self.timer.stop()
    }

    @MainActor
    func loadData() async {
        do {
            guard let currentDevice = configManager.currentDevice else {
                return
            }

            await MainActor.run { self.updateState = "Updating..." }
            await self.network.ensureHasToken()

            let raws = try await self.network.openapi_fetchRealData(deviceSN: currentDevice.deviceID, variables: [.feedinPower, .gridConsumptionPower, .generationPower, .loadsPower, .batChargePower, .batDischargePower].map { $0.variable })
            let currentViewModel = CurrentStatusViewModel(raws: raws)
            let battery = try currentDevice.battery != nil ? BatteryViewModel(from: await self.network.fetchBattery(deviceID: currentDevice.deviceID)) : .noBattery
            let summary = HomePowerFlowViewModel(solar: currentViewModel.currentSolarPower,
                                                 battery: battery.chargePower,
                                                 home: currentViewModel.currentHomeConsumption,
                                                 grid: currentViewModel.currentGridExport,
                                                 batteryStateOfCharge: battery.chargeLevel,
                                                 hasBattery: battery.hasBattery,
                                                 batteryTemperature: battery.temperature)
            self.calculateTicks(historicalViewModel: currentViewModel)
            await MainActor.run {
                self.summary = summary
            }
        } catch {
            await MainActor.run {
                self.updateState = error.localizedDescription
            }
        }
    }

    func calculateTicks(historicalViewModel: CurrentStatusViewModel) {
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
            }
        }
    }
}
