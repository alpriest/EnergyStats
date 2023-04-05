//
//  DeviceListDebugView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct DeviceListDebugView: View {
    @EnvironmentObject var network: InMemoryLoggingNetworkingDecorator

    var body: some View {
        ScrollView {
            if let deviceList = network.deviceListResponse {
                ForEach(deviceList.devices, id: \.self) { device in
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        alignment: .leading)
                    {
                        Text("plantName")
                        Text(device.plantName)

                        Text("deviceID")
                        Text(device.deviceID)

                        Text("deviceSN")
                        Text(device.deviceSN)

                        Text("hasBattery")
                        Text(device.hasBattery ? "YES" : "NO")

                        Text("hasPV")
                        Text(device.hasPV ? "YES" : "NO")
                    }
                    .padding(.bottom)
                }.padding()
            } else {
                Text("Device list is only fetched and recached on login, logout to see the data response.")
            }
        }
        .navigationTitle("Device List")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CopyButton(text: asText)
            }
        }
    }

    private var asText: String {
        guard let deviceList = network.deviceListResponse else { return "" }

        return deviceList.devices.map { device in
            """
            Plantname: \(device.plantName)
            DeviceID: \(device.deviceID)
            DeviceSN: \(device.deviceSN)
            Has Battery: \(device.hasBattery)
            Has PV: \(device.hasPV)
            """
        }.joined(separator: "\n")
    }
}

struct DeviceListDebugView_Previews: PreviewProvider {
    static var previews: some View {
        let network = InMemoryLoggingNetworkingDecorator(inner: DemoNetworking())
        Task { try await network.fetchDeviceList() }

        return DeviceListDebugView()
            .environmentObject(network)
    }
}
