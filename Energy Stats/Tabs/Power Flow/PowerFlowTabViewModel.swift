//
//  PowerFlowViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation
import UIKit
import Energy_Stats_Core

class PowerFlowTabViewModel: ObservableObject {
    private let network: Networking
    private(set) var configManager: ConfigManaging
    private let timer = CountdownTimer()
    @MainActor @Published private(set) var lastUpdated: String = Date().small()
    @MainActor @Published private(set) var updateState: String = "Updating..."
    @MainActor @Published private(set) var state: State = .unloaded
    private(set) var isLoading = false
    private var totalTicks = 60

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

    init(_ network: Networking, configManager: ConfigManager) {
        self.network = network
        self.configManager = configManager

        NotificationCenter.default.addObserver(self, selector: #selector(self.willResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func startTimer() async {
        await self.timer.start(totalTicks: self.totalTicks) { ticksRemaining in
            Task { @MainActor in
                self.updateState = "Next update in \(PreciseDateTimeFormatter.localizedString(from: ticksRemaining))"
            }
        } onCompletion: {
            Task {
                await self.timerFired()
            }
        }
    }

    func timerFired() async {
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
            if configManager.currentDevice == nil {
                try await self.configManager.findDevices()
            }

            guard let currentDevice = configManager.currentDevice else {
                self.state = .failed(nil, "No devices found. Please logout and try logging in again.")
                return
            }

            if case .failed = self.state {
                state = .unloaded
            }

            await MainActor.run { self.updateState = "Updating..." }
            await self.network.ensureHasToken()

            let raws = try await self.network.fetchRaw(deviceID: currentDevice.deviceID, variables: [.feedinPower, .gridConsumptionPower, .generationPower, .loadsPower, .batChargePower, .batDischargePower], queryDate: .current())
            let currentViewModel = CurrentStatusViewModel(raws: raws)
            let battery = currentDevice.battery != nil ? BatteryViewModel(from: try await self.network.fetchBattery(deviceID: currentDevice.deviceID)) : .noBattery
            let summary = HomePowerFlowViewModel(solar: currentViewModel.currentSolarPower,
                                                 battery: battery.chargePower,
                                                 home: currentViewModel.currentHomeConsumption,
                                                 grid: currentViewModel.currentGridExport,
                                                 batteryStateOfCharge: battery.chargeLevel,
                                                 hasBattery: battery.hasBattery,
                                                 batteryTemperature: battery.temperature)

            self.state = .loaded(.empty()) // refreshes the marching ants line speed
            try await Task.sleep(nanoseconds: 1000)
            self.state = .loaded(summary)
            self.calculateTicks(historicalViewModel: currentViewModel)
            self.updateState = " "
        } catch {
            await stopTimer()
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
                if totalTicks <= 0 {
                    totalTicks = 300
                }
            }
        }
    }

    @objc func didBecomeActiveNotification() {
        Task { await self.timerFired() }
    }

    @objc func willResignActiveNotification() {
        Task { await self.stopTimer() }
    }

    func sleep() async {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        } catch {}
    }
}
