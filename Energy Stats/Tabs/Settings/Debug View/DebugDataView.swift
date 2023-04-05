//
//  DebugDataView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct DebugDataView: View {
    @EnvironmentObject var network: InMemoryLoggingNetworkingDecorator

    var body: some View {
        Form {
            Section(content: {
                NavigationLink("Raw") {
                    RawResponseDebugView()
                }
                NavigationLink("Report") {
                    ReportResponseDebugView()
                }
                NavigationLink("Battery") {
                    BatteryDebugView()
                }
                NavigationLink("Device List") {
                    DeviceListDebugView()
                }
            }, footer: {
                Text("Having problems? View the most recent data logs above to help and diagnose issues")
            })

        }.navigationTitle("Network logs")
    }
}

struct DebugDataView_Previews: PreviewProvider {
    static var previews: some View {
        let network = InMemoryLoggingNetworkingDecorator(inner: DemoNetworking())
        Task {
            _ = try await network.fetchRaw(deviceID: "123", variables: [.batChargePower])
            _ = try await network.fetchReport(deviceID: "123", variables: [.chargeEnergyToTal], queryDate: .current())
            _ = try await network.fetchBattery(deviceID: "123")
            _ = try await network.fetchDeviceList()
        }

        return NavigationView {
            DebugDataView()
        }
        .environmentObject(network)
    }
}
