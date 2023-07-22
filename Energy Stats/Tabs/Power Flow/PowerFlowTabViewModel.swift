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
    private let timer = CountdownTimer()
    @MainActor @Published private(set) var lastUpdated: String = Date().small()
    @MainActor @Published private(set) var updateState: String = "Updating..."
    @MainActor @Published private(set) var state: State = .unloaded
    private(set) var isLoading = false
    private var totalTicks = 60
    private var cancellable: AnyCancellable?

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

    init(_ network: Networking, configManager: ConfigManaging) {
        self.network = network
        self.configManager = configManager

        NotificationCenter.default.addObserver(self, selector: #selector(self.willResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)

        self.addDeviceChangeObserver()
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
            if self.timer.isTicking == false {
                await self.timerFired()
            }
        }
    }

    func timerFired() async {
        guard self.isLoading == false else { return }

        await self.timer.stop()
        self.isLoading = true
        defer { isLoading = false }

        await self.loadData()
        await self.startTimer()

        self.addDeviceChangeObserver()
    }

    func addDeviceChangeObserver() {
        guard self.cancellable == nil else { return }

        self.cancellable = self.configManager.currentDevice.sink { device in
            guard device != nil else { return }

            Task {
                await self.timerFired()
            }
        }
    }

    func stopTimer() async {
        await self.timer.stop()
    }

    @MainActor
    func loadData() async {
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

            let earnings = try await self.network.fetchEarnings(deviceID: currentDevice.deviceID)
            let graphVariables = [configManager.variables.named("feedinPower"),
                                  self.configManager.variables.named("gridConsumptionPower"),
                                  self.configManager.variables.named("generationPower"),
                                  self.configManager.variables.named("loadsPower"),
                                  self.configManager.variables.named("batChargePower"),
                                  self.configManager.variables.named("batDischargePower")].compactMap { $0 }
            let raws = try await self.network.fetchRaw(deviceID: currentDevice.deviceID, variables: graphVariables, queryDate: .current())
            let currentViewModel = CurrentStatusViewModel(raws: raws)
            var battery: BatteryViewModel = .noBattery
            if currentDevice.battery != nil {
                do {
                    let response = try await self.network.fetchBattery(deviceID: currentDevice.deviceID)
                    battery = BatteryViewModel(from: response)
                } catch {}
            }

            let summary = HomePowerFlowViewModel(solar: currentViewModel.currentSolarPower,
                                                 battery: battery.chargePower,
                                                 home: currentViewModel.currentHomeConsumption,
                                                 grid: currentViewModel.currentGridExport,
                                                 batteryStateOfCharge: battery.chargeLevel,
                                                 hasBattery: battery.hasBattery,
                                                 batteryTemperature: battery.temperature,
                                                 batteryResidual: battery.residual,
                                                 todaysGeneration: earnings.today.generation,
                                                 earnings: self.makeEarnings(earnings))

            self.state = .loaded(.empty()) // refreshes the marching ants line speed
            try await Task.sleep(nanoseconds: 1000)
            self.state = .loaded(summary)
            self.calculateTicks(historicalViewModel: currentViewModel)
            self.updateState = " "
        } catch {
            await self.stopTimer()
            self.state = .failed(error, error.localizedDescription)
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

    @objc
    func deviceChanged() {
        Task { @MainActor in
            await self.timerFired()
        }
    }

    func sleep() async {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        } catch {}
    }

    private func makeEarnings(_ response: EarningsResponse) -> String {
        return "\(response.currency) \(response.today.earnings.roundedToString(decimalPlaces: 2)), \(response.month.earnings.roundedToString(decimalPlaces: 2)), \(response.year.earnings.roundedToString(decimalPlaces: 2)), \(response.cumulate.earnings.roundedToString(decimalPlaces: 2))"
    }
}
