//
//  InverterSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/08/2023.
//

import Energy_Stats_Core
import SwiftUI

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
    @Binding var showInverterScheduleQuickLink: Bool
    @Binding var ct2DisplayMode: CT2DisplayMode
    @Binding var shouldCombineCT2WithLoadsPower: Bool

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
                    Text("Show inverter temperature")
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

                Toggle(isOn: $showInverterScheduleQuickLink) {
                    Text("Show schedule quick link")
                }

            } header: {
                Text("Display Options")
            }

//            Section {
//                Toggle(isOn: $showInverterTemperature) {
//                    Text("Show BMS temperature")
//                }
//
//                Toggle(isOn: $showInverterTemperature) {
//                    Text("Show inverter temperature")
//                }
//            } header: {
//                Text("Inverter temperatures")
//            }

            Section {
                Toggle(isOn: $shouldInvertCT2) {
                    Text("Invert CT2 values when detected")
                }

                Toggle(isOn: $shouldCombineCT2WithPVPower) {
                    Text("Combine CT2 with PV power")
                }

                Toggle(isOn: $shouldCombineCT2WithLoadsPower) {
                    Text("Combine CT2 with Loads power")
                }

                HStack {
                    Text("CT2")
                    Spacer()
                    Picker("CT2 Display mode", selection: $ct2DisplayMode) {
                        Text("Hidden").tag(CT2DisplayMode.hidden)
                        Text("Icon").tag(CT2DisplayMode.separateIcon)
                        Text("As string").tag(CT2DisplayMode.asPowerString)
                    }.pickerStyle(.segmented)
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

            Section {
                NavigationLink("Advanced settings") {
                    AdvancedInverterSettingsView(config: configManager, networking: networking)
                }
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
                showInverterTypeName: .constant(true),
                showInverterScheduleQuickLink: .constant(true),
                ct2DisplayMode: .constant(.asPowerString),
                shouldCombineCT2WithLoadsPower: .constant(false)
            )
        }
    }
}
#endif
