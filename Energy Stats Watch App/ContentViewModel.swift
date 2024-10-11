//
//  ContentViewModel.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 30/04/2024.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct ContentData {
    let batterySOC: Double?
    let solar: Double?
    let house: Double?
    let grid: Double?
    let battery: Double?
    let lastUpdated: Date
    let totalExport: Double?
    let totalImport: Double?
}

@Observable
class ContentViewModel {
    let keychainStore: KeychainStoring
    let network: Networking
    let config: WatchConfigManaging
    var loadState: LoadState = .inactive
    var state: ContentData?
    private let FOUR_MINUTES_IN_SECONDS = 60.0 * 4.0

    init(keychainStore: KeychainStoring, network: Networking, config: WatchConfigManaging) {
        self.keychainStore = keychainStore
        self.network = network
        self.config = config
    }

    func loadData() async {
        guard let deviceSN: String = keychainStore.get(key: .deviceSN) else {
            loadState = .error(nil, "No Inverter Found\n\nEnsure you are logged in on your iOS app.")
            return
        }
        guard state.lastRefreshSeconds > FOUR_MINUTES_IN_SECONDS else {
            print("Data is fresh, not refreshing")
            return
        }
        print("Config Battery Capacity is", config.batteryCapacity)

        defer {
            Task { @MainActor in
                loadState = .inactive
            }
        }

        do {
            loadState = .active("Loading")
            let reals = try await network.fetchRealData(
                deviceSN: deviceSN,
                variables: [
                    "SoC",
                    "SoC_1",
                    "pvPower",
                    "feedinPower",
                    "gridConsumptionPower",
                    "generationPower",
                    "meterPower2",
                    "epsPower",
                    "batChargePower",
                    "batDischargePower",
                    "ResidualEnergy",
                    "batTemperature"
                ]
            )

            let device = Device(deviceSN: deviceSN, stationName: nil, stationID: "", battery: nil, moduleSN: "", deviceType: "", hasPV: true, hasBattery: true)
            let calculator = CurrentStatusCalculator(device: device,
                                                     response: reals,
                                                     config: config)

            let batteryViewModel = reals.makeBatteryViewModel()
            let batterySOC = reals.datas.SoC() / 100.0

            let totals = await loadTotals(device)

            withAnimation {
                self.state = ContentData(
                    batterySOC: batterySOC,
                    solar: calculator.currentSolarPower,
                    house: calculator.currentHomeConsumption,
                    grid: calculator.currentGrid,
                    battery: batteryViewModel.chargePower,
                    lastUpdated: Date.now,
                    totalExport: totals?.gridExport,
                    totalImport: totals?.gridImport
                )
            }

            try? await HomeEnergyStateManager.shared.calculateBatteryState(
                openQueryResponse: reals,
                batteryCapacityW: config.batteryCapacityW,
                minSOC: config.minSOC,
                showUsableBatteryOnly: config.showUsableBatteryOnly
            )
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            loadState = .error(error, "Could not load")
        }
    }

    private func makeBatteryViewModel(_ real: OpenQueryResponse) -> BatteryViewModel {
        let chargePower = real.datas.currentDouble(for: "batChargePower")
        let dischargePower = real.datas.currentDouble(for: "batDischargePower")
        let power = chargePower > 0 ? chargePower : -dischargePower

        return BatteryViewModel(
            power: power,
            soc: Int(real.datas.SoC()),
            residual: real.datas.currentDouble(for: "ResidualEnergy") * 10.0,
            temperature: real.datas.currentDouble(for: "batTemperature")
        )
    }

    private func loadTotals(_ device: Device) async -> TotalsViewModel? {
        guard config.showGridTotalsOnPowerFlow else { return nil }

        return try? TotalsViewModel(reports: await loadReportData(device))
    }

    private func loadReportData(_ currentDevice: Device) async throws -> [OpenReportResponse] {
        let reportVariables = [ReportVariable.feedIn, ReportVariable.gridConsumption]

        return try await network.fetchReport(deviceSN: currentDevice.deviceSN,
                                             variables: reportVariables,
                                             queryDate: .now(),
                                             reportType: .month)
    }
}

extension ContentData? {
    var lastRefreshSeconds: TimeInterval {
        guard let self else { return .infinity }

        return Date.now.timeIntervalSince(self.lastUpdated)
    }
}
