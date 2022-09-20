//
//  ContentViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation
import UIKit

class SummaryTabViewModel: ObservableObject {
    private let network: Networking
    private let timer = CountdownTimer()
    @MainActor @Published private(set) var lastUpdated: String = Date().small()
    @MainActor @Published private(set) var updateState: String = "Updating..."
    @MainActor @Published private(set) var state: State = .unloaded

    enum State {
        case unloaded
        case loaded(PowerFlowViewModel)
        case failed(String)
    }

    init(_ network: Networking) {
        self.network = network

        NotificationCenter.default.addObserver(self, selector: #selector(self.willResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func startTimer() {
        self.timer.start(totalTicks: 30) { ticksRemaining in
            Task { await MainActor.run { self.updateState = "Next update in \(ticksRemaining)s" } }
        } onCompletion: {
            Task {
                await self.timerFired()
            }
        }
    }

    func timerFired() async {
        self.stopTimer()
        await MainActor.run { self.updateState = "Updating..." }
        await self.loadData()
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        } catch {}

        self.startTimer()
    }

    func stopTimer() {
        self.timer.stop()
    }

    @MainActor
    func loadData() async {
        do {
            let historical = HistoricalViewModel(raw: try await self.network.fetchRaw(variables: [.feedinPower, .gridConsumptionPower, .pvPower, .loadsPower]))
            let battery = BatteryViewModel(from: try await self.network.fetchBattery())
            let summary = PowerFlowViewModel(solar: historical.currentSolarPower,
                                             battery: battery.chargePower,
                                             home: historical.currentHomeConsumption,
                                             grid: historical.currentGridExport,
                                             batteryStateOfCharge: battery.chargeLevel)

            self.state = .loaded(PowerFlowViewModel(solar: 0, battery: 0, home: 0, grid: 0, batteryStateOfCharge: 0))
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
        self.stopTimer()
    }
}
