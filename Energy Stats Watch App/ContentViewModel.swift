//
//  ContentViewModel.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 30/04/2024.
//

import Combine
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
    let network: Networking
    let config: WatchConfigManaging
    var loadState: LoadState = .inactive
    var state: ContentData?
    var deviceSN: String?
    private let FOUR_MINUTES_IN_SECONDS = 60.0 * 4.0
    private var cancellables = Set<AnyCancellable>()

    init(network: Networking, config: WatchConfigManaging) {
        self.network = network
        self.config = config
        self.deviceSN = config.deviceSN

        config.isLoggedInPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                guard let self else { return }

                if isLoggedIn {
                    if deviceSN != config.deviceSN {
                        self.deviceSN = config.deviceSN
                        Task { await self.loadData() }
                    }
                } else {
                    loadState = .error(nil, "No device/API key found. Open Energy Stats on your phone to sync.2")
                    state = nil
                }
            }
            .store(in: &cancellables)
    }

    func loadData() async {
        guard let deviceSN, config.isLoggedIn else {
            loadState = .error(nil, "No device/API key found. Open Energy Stats on your phone to sync.3")
            return
        }
        guard state.lastRefreshSeconds > FOUR_MINUTES_IN_SECONDS else {
            return
        }

        defer {
            Task { @MainActor in
                loadState = .inactive
            }
        }

        do {
            loadState = .active(.loading)
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
                    "batChargePower",
                    "batDischargePower",
                    "ResidualEnergy",
                    "batTemperature",
                    "batTemperature_1",
                    "batTemperature_2",
                ]
            )

            let device = Device(deviceSN: deviceSN, stationName: nil, stationID: "", battery: nil, moduleSN: "", deviceType: "", hasPV: true, hasBattery: true, productType: nil)
            let currentStatusCalculator = CurrentStatusCalculator(device: device,
                                                                  response: reals,
                                                                  config: config)
            let values = currentStatusCalculator.currentValues()

            let batteryViewModel = BatteryViewModel.make(currentDevice: device, real: reals)
            let totals = await loadTotals(device)

            withAnimation {
                self.state = ContentData(
                    batterySOC: batteryViewModel.chargeLevel,
                    solar: values.solarPower,
                    house: values.homeConsumption,
                    grid: values.grid,
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

    private func loadTotals(_ device: Device) async -> TotalsViewModel? {
        guard config.showGridTotalsOnPowerFlow else { return nil }

        return try? TotalsViewModel(reports: await loadReportData(device), generationViewModel: nil)
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
