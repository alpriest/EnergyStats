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
    @MainActor @Published private(set) var updateState: String = "Updating..."
    @MainActor @Published private(set) var state: State = .unloaded

    enum State {
        case unloaded
        case loaded(PowerFlowViewModel)
        case failed(String)
    }
    
    init(_ network: Networking) {
        self.network = network
    }
    
    func startTimer() {
        timer.start(totalTicks: 30) { ticksRemaining in
            Task { await MainActor.run { self.updateState = "Next update in \(ticksRemaining)s" } }
        } onCompletion: {
            Task { await MainActor.run { self.updateState = "Updating..." } }
            Task {
                await self.loadData()
                self.startTimer()
            }
        }
    }

    func stopTimer() {
        timer.stop()
    }

    @MainActor
    func loadData() async {
        do {
            let historical = HistoricalViewModel(raw: try await self.network.fetchRaw(variables: ["feedinPower", "generationPower", "gridConsumptionPower", "batChargePower", "batDischargePower", "pvPower", "loadsPower"]))
            let battery = BatteryViewModel(from: try await self.network.fetchBattery())
            let summary = PowerFlowViewModel(solar: historical.currentSolarPower,
                                             battery: battery.chargePower,
                                             home: historical.currentHomeConsumption,
                                             grid: historical.currentGridExport,
                                             batteryStateOfCharge: battery.chargeLevel)

            self.state = .loaded(PowerFlowViewModel(solar: 0, battery: 0, home: 0, grid: 0, batteryStateOfCharge: 0))
            self.state = .loaded(summary)
        } catch {
            self.state = .failed(error.localizedDescription)
        }
    }
}
