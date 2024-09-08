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
    @State private var alert: AlertContent?

    @EnvironmentObject var store: InMemoryLoggingNetworkStore
    let networking: Networking
    let configManager: ConfigManaging

    var body: some View {
        Form {
            Section(content: {
                NavigationLink(String(stringLiteral: "device/report/Query")) {
                    ResponseDebugView<[OpenReportResponse]>(
                        store: store,
                        title: String(stringLiteral: "device/report/Query"),
                        missing: "Data is only fetched and cached on the graph view. Click that page to load report data",
                        mapper: { $0.reportResponse },
                        fetcher: nil
                    )
                }

                NavigationLink(String(stringLiteral: "device/real/Query")) {
                    ResponseDebugView<OpenQueryResponse>(
                        store: store,
                        title: String(stringLiteral: "device/real/Query"),
                        missing: "Data is fetched and cached on the power flow view",
                        mapper: { $0.queryResponse },
                        fetcher: nil
                    )
                }

                NavigationLink(String(stringLiteral: "device/list")) {
                    ResponseDebugView<[DeviceSummaryResponse]>(
                        store: store,
                        title: String(stringLiteral: "device/list"),
                        missing: "Data is fetched and cached on login",
                        mapper: { $0.deviceListResponse },
                        fetcher: nil
                    )
                }

                NavigationLink(String(stringLiteral: "device/detail")) {
                    ResponseDebugView<DeviceDetailResponse>(
                        store: store,
                        title: String(stringLiteral: "device/detail"),
                        missing: "Data is fetched and cached on login",
                        mapper: { $0.deviceDetailResponse },
                        fetcher: {
                            guard let selectedDeviceSN = configManager.selectedDeviceSN else { return }

                            _ = try await networking.fetchDevice(deviceSN: selectedDeviceSN)
                        }
                    )
                }

                NavigationLink(String(stringLiteral: "device/variable/get")) {
                    ResponseDebugView<OpenApiVariableArray>(
                        store: store,
                        title: String(stringLiteral: "device/variable/get"),
                        missing: "Data is fetched and cached on login",
                        mapper: { $0.variables },
                        fetcher: nil
                    )
                }

                NavigationLink(String(stringLiteral: "device/battery/soc/get")) {
                    ResponseDebugView<BatterySOCResponse>(
                        store: store,
                        title: String(stringLiteral: "device/battery/soc/get"),
                        missing: "Battery Settings are fetched and recached on login. Logout and login to see the data response, or tap below",
                        mapper: { $0.batterySOCResponse },
                        fetcher: {
                            if let deviceSN = configManager.currentDevice.value?.deviceSN {
                                _ = try await networking.fetchBatterySettings(deviceSN: deviceSN)
                            } else {
                                throw NoCurrentDeviceFoundError()
                            }
                        }
                    )
                }

                NavigationLink(String(stringLiteral: "device/battery/forceChargeTime/get")) {
                    ResponseDebugView<BatteryTimesResponse>(
                        store: store,
                        title: String(stringLiteral: "device/battery/forceChargeTime/get"),
                        missing: "Battery Charge Times are fetched on demand. Tap below to fetch now",
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

                NavigationLink(String(stringLiteral: "latest request/response")) {
                    ResponseDebugView<RequestResponseData>(
                        store: store,
                        title: String(stringLiteral: "latest request/response"),
                        missing: "No requests made. Seems odd.",
                        mapper: { $0.latestRequestResponseData },
                        fetcher: nil
                    )
                }

                Button {
                    Task {
                        let counts = try await networking.fetchRequestCount()
                        alert = AlertContent(title: nil, message: LocalizedStringKey("\(counts.remaining) remaining out of \(counts.total) total"))
                    }
                } label: {
                    Text("debug.view_request_count")
                }
            }, footer: {
                Text("debug.footer_text")
            })
        }
        .navigationTitle("debug.navigation_title")
        .alert(alertContent: $alert)
    }
}

#if DEBUG
struct DebugDataView_Previews: PreviewProvider {
    static var previews: some View {
        let api = NetworkService.preview()
        let store = InMemoryLoggingNetworkStore()
        Task {
            store.queryResponse = try NetworkOperation(
                description: "fetchRaw",
                value: await api.fetchRealData(deviceSN: "123", variables: [Variable(name: "BatChargePower", variable: "batChargePower", unit: "kW")].map { $0.variable }),
                raw: "test".data(using: .utf8)!
            )
            store.reportResponse = try NetworkOperation(
                description: "fetchReport",
                value: await api.fetchReport(deviceSN: "123", variables: [.chargeEnergyToTal], queryDate: .now(), reportType: .day),
                raw: "test".data(using: .utf8)!
            )
            store.deviceListResponse = try NetworkOperation(
                description: "fetchDeviceList",
                value: await api.fetchDeviceList(),
                raw: "test".data(using: .utf8)!
            )
        }

        return NavigationView {
            DebugDataView(networking: api, configManager: ConfigManager.preview())
        }
        .environmentObject(store)
    }
}
#endif
