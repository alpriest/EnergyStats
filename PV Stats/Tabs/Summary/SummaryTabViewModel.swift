//
//  ContentViewModel.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

class SummaryTabViewModel: ObservableObject {
    private let network: Networking
    private let timer = CountdownTimer()
    @MainActor @Published private(set) var lastUpdated: String = Date().small()
    @MainActor @Published private(set) var summary: PowerFlowViewModel?
    @MainActor @Published private(set) var updateState: String = "Updating..."
    
    init(_ network: Networking) {
        self.network = network
    }
    
    func startTimer() {
        timer.start(totalTicks: 5) { ticksRemaining in
            Task { await MainActor.run { self.updateState = "Next update in \(ticksRemaining)s" } }
        } onCompletion: {
            Task { await MainActor.run { self.updateState = "Updating..." } }
            self.loadData()
//            self.startTimer()
        }
    }

    func stopTimer() {
        timer.stop()
    }

    func loadData() {
        Task {
            do {
                let historical = HistoricalViewModel(raw: try await self.network.fetchRaw())
                let battery = BatteryViewModel(from: try await self.network.fetchBattery())
                let summary = PowerFlowViewModel(solar: historical.currentSolarPower,
                                                 battery: battery.chargePower,
                                                 home: historical.currentHomeConsumption,
                                                 grid: historical.currentGridExport,
                                                 batteryStateOfCharge: battery.chargeLevel)

                await MainActor.run {
                    self.summary = summary
                    self.updateState = "done"
                }
            } catch {
                print(error)
            }
        }
    }
}
