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
                        title: "Device List",
                        missing: "Device list is only fetched and recached on login, logout to see the data response.",
                        mapper: { $0.deviceListResponse }
                    )
                }
                NavigationLink("Firmware Versions") {
                    ResponseDebugView<AddressBookResponse>(
                        title: "Firmware Versions",
                        missing: "Device list is only fetched and recached on login, logout to see the data response.",
                        mapper: { $0.addressBookResponse }
                    )
                }
            }, footer: {
                Text("Having problems? View the most recent data logs above to help diagnose issues")
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
            store.rawResponse = try NetworkOperation(description: "fetchRaw", value: await network.fetchRaw(deviceID: "123", variables: [RawVariable(name: "BatChargePower", variable: "batChargePower", unit: "kW")], queryDate: .current()), raw: "test".data(using: .utf8)!)
            store.reportResponse = try NetworkOperation(description: "fetchReport", value: await network.fetchReport(deviceID: "123", variables: [.chargeEnergyToTal], queryDate: .current(), reportType: .day), raw: "test".data(using: .utf8)!)
            store.batteryResponse = try NetworkOperation(description: "fetchBattery", value: await network.fetchBattery(deviceID: "123"), raw: "test".data(using: .utf8)!)
            store.deviceListResponse = try NetworkOperation(description: "fetchDeviceList", value: await network.fetchDeviceList(), raw: "test".data(using: .utf8)!)
        }

        return NavigationView {
            DebugDataView()
        }
        .environmentObject(store)
    }
}
#endif
