//
//  PowerFlowViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation
import UIKit

class PowerFlowTabViewModel: ObservableObject {
    private let network: Networking
    private var configManager: ConfigManager
    private let timer = CountdownTimer()
    @MainActor @Published private(set) var lastUpdated: String = Date().small()
    @MainActor @Published private(set) var updateState: String = "Updating..."
    @MainActor @Published private(set) var state: State = .unloaded
    private(set) var isLoading = false
    private let secondsBetweenRefresh = 30

    enum State: Equatable {
        case unloaded
        case loaded(HomePowerFlowViewModel)
        case failed(String)
    }

    init(_ network: Networking, configManager: ConfigManager) {
        self.network = network
        self.configManager = configManager

        NotificationCenter.default.addObserver(self, selector: #selector(self.willResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func startTimer() async {
        await self.timer.start(totalTicks: secondsBetweenRefresh) { ticksRemaining in
            Task { @MainActor in self.updateState = "Next update in \(ticksRemaining)s" }
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
            await MainActor.run { self.updateState = "Updating..." }
            await self.network.ensureHasToken()
            let historical = HistoricalViewModel(raws: try await self.network.fetchRaw(variables: [.feedinPower, .gridConsumptionPower, .pvPower, .loadsPower]))
            let battery = configManager.hasBattery ? BatteryViewModel(from: try await self.network.fetchBattery()) : BatteryViewModel.noBattery
            let summary = HomePowerFlowViewModel(configManager: configManager,
                                                 solar: historical.currentSolarPower,
                                                 battery: battery.chargePower,
                                                 home: historical.currentHomeConsumption,
                                                 grid: historical.currentGridExport,
                                                 batteryStateOfCharge: battery.chargeLevel,
                                                 hasBattery: battery.hasBattery)

            self.state = .loaded(.empty(configManager: configManager)) // refreshes the moving line
            try await Task.sleep(nanoseconds: 1000)
            self.state = .loaded(summary)
            self.updateState = " "
        } catch {
            self.state = .failed(String(describing: error))
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
