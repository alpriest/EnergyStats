//
//  DebugDataView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct DebugDataView: View {
    struct NoCurrentDeviceFoundError: Error {}

    @EnvironmentObject var store: InMemoryLoggingNetworkStore
    let networking: FoxESSNetworking
    let configManager: ConfigManaging

    var body: some View {
        Form {
            Section(content: {
                NavigationLink("Raw") {
                    ResponseDebugView<[RawResponse]>(
                        store: store,
                        title: "Raw",
                        missing: "Data is fetched and cached on the power flow view.",
                        mapper: { $0.rawResponse },
                        fetcher: nil
                    )
                }
                NavigationLink("Report") {
                    ResponseDebugView<[ReportResponse]>(
                        store: store,
                        title: "Report",
                        missing: "Data is only fetched and cached on the graph view. Click that page to load report data",
                        mapper: { $0.reportResponse },
                        fetcher: nil
                    )
                }
                NavigationLink("Battery") {
                    ResponseDebugView<BatteryResponse>(
                        store: store,
                        title: "Battery",
                        missing: "Data is fetched and cached on the power flow view.",
                        mapper: { $0.batteryResponse },
                        fetcher: {
                            if let deviceID = configManager.currentDevice.value?.deviceID {
                                _ = try await networking.fetchBattery(deviceID: deviceID)
                            } else {
                                throw NoCurrentDeviceFoundError()
                            }
                        }
                    )
                }
                NavigationLink("Battery Settings") {
                    ResponseDebugView<BatterySettingsResponse>(
                        store: store,
                        title: "Battery Settings",
                        missing: "Battery Settings are fetched and recached on login. Logout and login to see the data response, or tap below",
                        mapper: { $0.batterySettingsResponse },
                        fetcher: {
                            if let deviceSN = configManager.currentDevice.value?.deviceSN {
                                _ = try await networking.fetchBatterySettings(deviceSN: deviceSN)
                            } else {
                                throw NoCurrentDeviceFoundError()
                            }
                        }
                    )
                }
                NavigationLink("Battery Times") {
                    ResponseDebugView<BatteryTimesResponse>(
                        store: store,
                        title: "Battery Times",
                        missing: "Battery Times are fetched on demand.",
                        mapper: { $0.batteryTimesResponse },
                        fetcher: {
                            if let deviceSN = configManager.currentDevice.value?.deviceSN {
                                _ = try await networking.fetchBatteryTimes(deviceSN: deviceSN)
                            } else {
                                throw NoCurrentDeviceFoundError()
                            }
                        }
                    )
                }
                NavigationLink("Device List") {
                    ResponseDebugView<[PagedDeviceListResponse.Device]>(
                        store: store,
                        title: "Device List",
                        missing: "Device list is fetched and recached on login, logout and login to see the data response.",
                        mapper: { $0.deviceListResponse },
                        fetcher: {
                            _ = try await networking.fetchDeviceList()
                        }
                    )
                }
                NavigationLink("Firmware Versions") {
                    ResponseDebugView<AddressBookResponse>(
                        store: store,
                        title: "Firmware Versions",
                        missing: "Firmware version is fetched and recached on login, logout and login to see the data response.",
                        mapper: { $0.addressBookResponse },
                        fetcher: {
                            if let deviceID = configManager.currentDevice.value?.deviceID {
                                _ = try await networking.fetchAddressBook(deviceID: deviceID)
                            } else {
                                throw NoCurrentDeviceFoundError()
                            }
                        }
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
            store.rawResponse = try NetworkOperation(description: "fetchRaw", value: await network.fetchRaw(deviceID: "123", variables: [RawVariable(name: "BatChargePower", variable: "batChargePower", unit: "kW")], queryDate: .now()), raw: "test".data(using: .utf8)!)
            store.reportResponse = try NetworkOperation(description: "fetchReport", value: await network.fetchReport(deviceID: "123", variables: [.chargeEnergyToTal], queryDate: .now(), reportType: .day), raw: "test".data(using: .utf8)!)
            store.batteryResponse = try NetworkOperation(description: "fetchBattery", value: await network.fetchBattery(deviceID: "123"), raw: "test".data(using: .utf8)!)
            store.deviceListResponse = try NetworkOperation(description: "fetchDeviceList", value: await network.fetchDeviceList(), raw: "test".data(using: .utf8)!)
        }

        return NavigationView {
            DebugDataView(networking: network, configManager: PreviewConfigManager())
        }
        .environmentObject(store)
    }
}
#endif
