//
//  BatteryDebugView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct BatteryDebugView: View {
    @EnvironmentObject var network: InMemoryLoggingNetworkingDecorator

    var body: some View {
        ScrollView {
            if let batteryResponse = network.batteryResponse {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    Text("Power")
                    Text(batteryResponse.power, format: .number)

                    Text("Residual")
                    Text(batteryResponse.residual, format: .number)

                    Text("SOC")
                    Text(batteryResponse.soc, format: .number)

                    Text("Temperature")
                    Text(batteryResponse.temperature, format: .number)
                }
            }
        }
        .navigationTitle("Battery")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CopyButton(text: asText)
            }
        }
    }

    private var asText: String {
        guard let batteryResponse = network.batteryResponse else { return "" }

        return """
        Power: \(batteryResponse.power)
        Residual: \(batteryResponse.residual)
        SOC: \(batteryResponse.soc)
        Temperature: \(batteryResponse.temperature)
        """
    }
}
