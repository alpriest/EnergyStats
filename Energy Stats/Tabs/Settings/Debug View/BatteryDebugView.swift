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
            if let response = network.batteryResponse {
                Text("Last fetched ") +
                Text(response.time, formatter: DateFormatter.forDebug())

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    Text("Power")
                    Text(response.data.power, format: .number)

                    Text("Residual")
                    Text(response.data.residual, format: .number)

                    Text("SOC")
                    Text(response.data.soc, format: .number)

                    Text("Temperature")
                    Text(response.data.temperature, format: .number)
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
        Power: \(batteryResponse.data.power)
        Residual: \(batteryResponse.data.residual)
        SOC: \(batteryResponse.data.soc)
        Temperature: \(batteryResponse.data.temperature)
        """
    }
}
