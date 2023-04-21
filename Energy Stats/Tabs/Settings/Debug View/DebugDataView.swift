//
//  DebugDataView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct DebugDataView: View {
    @EnvironmentObject var network: InMemoryLoggingNetworkStore

    var body: some View {
        Form {
            Section(content: {
                NavigationLink("Raw") {
                    ResponseDebugView<[RawResponse]>(
                        title: "Raw",
                        missing: "Data is fetched and cached on the power flow view.",
                        mapper: { $0.rawResponse }
                    )
                }
                NavigationLink("Report") {
                    ResponseDebugView<[ReportResponse]>(
                        title: "Report",
                        missing: "Data is only fetched and cached on the graph view. Click that page to load report data",
                        mapper: { $0.reportResponse }
                    )
                }
                NavigationLink("Battery") {
                    ResponseDebugView<BatteryResponse>(
                        title: "Battery",
                        missing: "Data is fetched and cached on the power flow view.",
                        mapper: { $0.batteryResponse }
                    )
                }
                NavigationLink("Device List") {
                    ResponseDebugView<PagedDeviceListResponse>(
                        title: "Battery",
                        missing: "Device list is only fetched and recached on login, logout to see the data response.",
                        mapper: { $0.deviceListResponse }
                    )
                }
            }, footer: {
                Text("Having problems? View the most recent data logs above to help and diagnose issues")
            })

        }.navigationTitle("Network logs")
    }
}

#if DEBUG
struct DebugDataView_Previews: PreviewProvider {
    static var previews: some View {
        let network = DemoNetworking()
        let store = InMemoryLoggingNetworkStore()
        Task {
            store.rawResponse = NetworkOperation(description: "fetchRaw", value: try await network.fetchRaw(deviceID: "123", variables: [.batChargePower], queryDate: .current()), raw: "test".data(using: .utf8)!)
            store.reportResponse = NetworkOperation(description: "fetchReport", value: try await network.fetchReport(deviceID: "123", variables: [.chargeEnergyToTal], queryDate: .current()), raw: "test".data(using: .utf8)!)
            store.batteryResponse = NetworkOperation(description: "fetchBattery", value: try await network.fetchBattery(deviceID: "123"), raw: "test".data(using: .utf8)!)
            store.deviceListResponse = NetworkOperation(description: "fetchDeviceList", value: try await network.fetchDeviceList(), raw: "test".data(using: .utf8)!)
        }

        return NavigationView {
            DebugDataView()
        }
        .environmentObject(store)
    }
}
#endif
