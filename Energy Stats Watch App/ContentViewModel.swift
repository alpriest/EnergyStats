//
//  ContentViewModel.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 30/04/2024.
//

import Energy_Stats_Core
import SwiftUI

struct ContentData {
    let batterySOC: Double?
    let solar: Double?
    let house: Double?
    let grid: Double?
    let battery: Double?
    let lastUpdated: Date
}

@Observable
class ContentViewModel {
    let keychainStore: KeychainStoring
    let network: Networking
    let configManager: ConfigManaging
    var loadState: LoadState = .inactive
    var state: ContentData?
    private let FOUR_MINUTES_IN_SECONDS = 60.0 * 4.0

    init(keychainStore: KeychainStoring, network: Networking, configManager: ConfigManaging) {
        self.keychainStore = keychainStore
        self.network = network
        self.configManager = configManager
    }

    func loadData() async {
        guard let deviceSN = keychainStore.getSelectedDeviceSN() else {
            loadState = .error(nil, "No Inverter Found\n\nEnsure you are logged in on your iOS app.")
            return
        }
        guard state.lastRefreshSeconds > FOUR_MINUTES_IN_SECONDS else {
            print("Data is fresh, not refreshing")
            return
        }

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
                                                     config: configManager)

            let batteryViewModel = makeBatteryViewModel(device, reals)

            withAnimation {
                self.state = ContentData(
                    batterySOC: reals.datas.SoC() / 100.0,
                    solar: calculator.currentSolarPower,
                    house: calculator.currentHomeConsumption,
                    grid: calculator.currentGrid,
                    battery: batteryViewModel.chargePower,
                    lastUpdated: Date.now
                )
            }
        } catch {
            loadState = .error(error, "Could not load")
        }
    }

    private func makeBatteryViewModel(_ currentDevice: Device, _ real: OpenQueryResponse) -> BatteryViewModel {
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
}

extension ContentData? {
    var lastRefreshSeconds: TimeInterval {
        guard let self else { return .infinity }

        return Date.now.timeIntervalSince(self.lastUpdated)
    }
}
