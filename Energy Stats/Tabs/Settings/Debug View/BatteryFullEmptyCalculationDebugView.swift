//
//  BatteryFullEmptyCalculationDebugView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 17/10/2024.
//

import Energy_Stats_Core
import SwiftUI

struct BatteryFullEmptyCalculationDebugView: View {
    let config: ConfigManaging
    let network: Networking
    @State var batteryChargePowerkW: Double = 0
    @State var batteryStateOfCharge: Double = 0
    @State var capacityW: Int = 0
    @State var minimumSOC: Double = 0
    @State var batteryChargeStatusDescription = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Battery Calculations")
                .font(.largeTitle)

            Text("Battery power: \(batteryChargePowerkW.kW(3))")
            Text("ABS Battery power: \(abs(batteryChargePowerkW).kW(3))")
            Text("Battery SoC: \(batteryStateOfCharge, format: .percent)")
            Text("Battery capacity: \(capacityW)W")
            Text("Min SoC: \(minimumSOC, format: .percent)")
            Text("Description: \(batteryChargeStatusDescription)")
            Text("Show only usable capacity? \(config.showUsableBatteryOnly)")
            Text("Device SN: \(config.selectedDeviceSN ?? "???")")
        }.onAppear {
            Task {
                try? await load()
            }
        }
    }

    private func load() async throws {
        let calculator = BatteryCapacityCalculator(
            capacityW: config.batteryCapacityW,
            minimumSOC: config.minSOC
        )
        minimumSOC = config.minSOC
        capacityW = config.batteryCapacityW

        guard let device = config.currentDevice.value else { return }
        let real = try await loadRealData(device, config: config)
        let batteryViewModel = BatteryViewModel.make(currentDevice: device, real: real)

        batteryChargeStatusDescription = calculator.batteryChargeStatusDescription(
            batteryChargePowerkW: batteryViewModel.chargePower,
            batteryStateOfCharge: batteryViewModel.chargeLevel
        ) ?? "(not discharging/charging)"
        batteryChargePowerkW = batteryViewModel.chargePower
        batteryStateOfCharge = batteryViewModel.chargeLevel
    }

    private func loadRealData(_ currentDevice: Device, config: ConfigManaging) async throws -> OpenQueryResponse {
        var variables = [
            "feedinPower",
            "gridConsumptionPower",
            "loadsPower",
            "generationPower",
            "pvPower",
            "meterPower2",
            "ambientTemperation",
            "invTemperation",
            "batChargePower",
            "batDischargePower",
            "SoC",
            "SoC_1",
            "batTemperature",
            "ResidualEnergy",
            "epsPower"
        ]

        if config.powerFlowStrings.enabled {
            variables.append(contentsOf: config.powerFlowStrings.variableNames())
        }

        return try await self.network.fetchRealData(
            deviceSN: currentDevice.deviceSN,
            variables: variables
        )
    }
}

#Preview {
    BatteryFullEmptyCalculationDebugView(
        config: ConfigManager.preview(),
        network: NetworkService.preview(),
        batteryChargePowerkW: 0.99,
        batteryStateOfCharge: 0.52
    )
}
