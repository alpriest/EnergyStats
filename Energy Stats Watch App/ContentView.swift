//
//  ContentView.swift
//  Energy Stats Watch App Watch App
//
//  Created by Alistair Priest on 27/04/2024.
//

import Energy_Stats_Core
import SwiftUI

struct ContentView: View {
    let keychainStore: KeychainStoring
    let network: Networking
    let configManager: ConfigManaging
    @State private var batterySOC: Double?
    @State private var solar: Double?
    @State private var house: Double?
    @State private var grid: Double?
    @State private var battery: Double?
    @State private var loadState: LoadState = .inactive

    private enum Constants {
        static let iconWidth: CGFloat = 34.0
        static let iconHeight: CGFloat = 34.0
    }

    var body: some View {
        VStack {
            Grid {
                GridRow(alignment: .top) {
                    solarView()
                    Spacer()
                    homeView()
                }

                Spacer(minLength: 30)

                GridRow(alignment: .top) {
                    batteryView()
                    Spacer(minLength: 15)
                    gridView()
                }
            }
            .loadable(loadState, overlay: true, retry: { Task { await loadData() }})
        }
        .task {
            Task { await loadData() }
        }
        .padding()
    }

    func solarView() -> some View {
        VStack(alignment: .center) {
            if let solar {
                SunView(solar: solar, sunSize: 18)
                    .frame(width: Constants.iconWidth, height: Constants.iconHeight)

                Text(solar.kWh(2))
                    .multilineTextAlignment(.center)
            } else {
                SunView(solar: 0)
                    .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                    .redacted(reason: .placeholder)

                Text("xxxxx")
                    .redacted(reason: .placeholder)
            }
        }
    }

    func batteryView() -> some View {
        VStack(alignment: .center) {
            Image(systemName: "minus.plus.batteryblock.fill")
                .font(.system(size: 36))
                .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                .foregroundStyle(battery.tintColor)

            if let batterySOC, let battery {
                Text(abs(battery).kWh(2))
                Text(batterySOC, format: .percent)
            } else {
                Text("xxxxx")
                    .redacted(reason: .placeholder)
            }
        }
    }

    func homeView() -> some View {
        VStack(alignment: .center) {
            Image(systemName: "house.fill")
                .font(.system(size: 36))
                .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                .foregroundStyle(.tint)

            if let house {
                Text(house.kW(2))
            } else {
                Text("xxxxx")
                    .redacted(reason: .placeholder)
            }
        }
    }

    func gridView() -> some View {
        VStack(alignment: .center) {
            PylonView()
                .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                .foregroundStyle(grid.tintColor)

            HStack {
                if let grid {
                    Text(abs(grid).kWh(2))
                } else {
                    Text("xxxxx")
                        .redacted(reason: .placeholder)
                }
            }
        }
    }

    private func loadData() async {
        guard let deviceSN = keychainStore.getSelectedDeviceSN() else { return }

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
                batterySOC = reals.datas.SoC() / 100.0
                battery = batteryViewModel.chargePower
                solar = calculator.currentSolarPower
                grid = calculator.currentGrid
                house = calculator.currentHomeConsumption
                loadState = .inactive
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

extension Double? {
    var tintColor: Color {
        guard let self else { return Color.primary }

        if self < 0 {
            return Color.linesNegative
        } else if self > 0 {
            return Color.linesPositive
        } else {
            return Color.linesNotFlowing
        }
    }
}

#Preview {
    ContentView(keychainStore: PreviewKeychainStore(), network: DemoNetworking(), configManager: PreviewConfigManager())
}
