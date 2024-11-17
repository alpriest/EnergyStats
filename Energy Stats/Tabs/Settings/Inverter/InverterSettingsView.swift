//
//  InverterSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/08/2023.
//

import Energy_Stats_Core
import SwiftUI

struct FirmwareLoadingView: View {
    @State private var loading = false
    @State private var firmwareVersions: DeviceFirmwareVersion? = nil
    let configManager: ConfigManaging
    let networking: Networking

    var body: some View {
        if let firmwareVersions {
            InverterFirmwareVersionsView(viewModel: firmwareVersions)
        } else if let selectedDeviceSN = configManager.selectedDeviceSN {
            if loading {
                HStack {
                    Text("Loading")
                    Spacer()
                    ProgressView()
                }
            } else {
                Button {
                    Task {
                        defer {
                            loading = false
                        }

                        loading = true
                        if let response = try? await networking.fetchDevice(deviceSN: selectedDeviceSN) {
                            firmwareVersions = DeviceFirmwareVersion(master: response.masterVersion, slave: response.slaveVersion, manager: response.managerVersion)
                        }
                    }
                } label: {
                    Text("Load firmware versions")
                }
            }
        }
    }
}

struct InverterSettingsView: View {
    let networking: Networking
    let configManager: ConfigManaging
    let templateStore: TemplateStoring
    @Binding var showInverterTemperature: Bool
    @Binding var showInverterIcon: Bool
    @Binding var shouldInvertCT2: Bool
    @Binding var showInverterStationName: Bool
    @Binding var shouldCombineCT2WithPVPower: Bool
    @Binding var showInverterTypeName: Bool

    var body: some View {
        Form {
            InverterChoiceView(viewModel: InverterChoiceViewModel(configManager: configManager))

            Section {
                NavigationLink("Manage schedules") {
                    ScheduleSummaryView(networking: networking, config: configManager, templateStore: templateStore)
                }
            }

            Section {
                Toggle(isOn: $showInverterTemperature) {
                    Text("Show inverter temperatures")
                }

                Toggle(isOn: $showInverterIcon) {
                    Text("Show inverter icon")
                }

                Toggle(isOn: $showInverterStationName) {
                    Text("Show inverter station name")
                }

                Toggle(isOn: $showInverterTypeName) {
                    Text("Show inverter type name")
                }
            } header: {
                Text("Display Options")
            }

            Section {
                Toggle(isOn: $shouldInvertCT2) {
                    Text("Invert CT2 values when detected")
                }

                Toggle(isOn: $shouldCombineCT2WithPVPower) {
                    Text("Combine CT2 with PV power")
                }
            } header: {
                Text("CT2 Settings")
            } footer: {
                Text("invert_ct2_footnote")
            }

            FirmwareLoadingView(configManager: configManager, networking: networking)

            if let currentDevice = configManager.currentDevice.value {
                Section {
                    ESLabeledText("Device Serial No.", value: currentDevice.deviceSN)
                    ESLabeledText("Module Serial No.", value: currentDevice.moduleSN)
                    ESLabeledText("Station name", value: currentDevice.stationName)
                }
                .contentShape(Rectangle())
                .alertCopy(text(currentDevice))
            }
        }
        .navigationTitle(.inverter)
    }

    func text(_ currentDevice: Device) -> String {
        [
            makePair("Station name", value: currentDevice.stationName),
            makePair("Device Serial No.", value: currentDevice.deviceSN),
            makePair("Module Serial No.", value: currentDevice.moduleSN)
        ]
        .compactMap { $0 }
        .joined(separator: "\n")
    }

    private func makePair(_ title: String, value: String?) -> String {
        "\(title) \(value ?? "unknown")"
    }
}

#if DEBUG
struct InverterSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InverterSettingsView(
                networking: NetworkService.preview(),
                configManager: ConfigManager.preview(),
                templateStore: TemplateStore.preview(),
                showInverterTemperature: .constant(true),
                showInverterIcon: .constant(true),
                shouldInvertCT2: .constant(true),
                showInverterStationName: .constant(true),
                shouldCombineCT2WithPVPower: .constant(true),
                showInverterTypeName: .constant(true)
            )
        }
    }
}
#endif

struct ESLabeledContent<Content: View>: View {
    let title: String
    let content: () -> Content

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        Group {
            LabeledContent(title, content: content)
        }
    }
}

struct ESLabeledText: View {
    let title: String
    let value: String?

    init(_ title: String, value: String?) {
        self.title = title
        self.value = value
    }

    var body: some View {
        Group {
            if let value {
                LabeledContent(title, value: value)
            }
        }
    }
}
