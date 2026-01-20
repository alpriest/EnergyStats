//
//  BatterySettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/03/2023.
//

import Energy_Stats_Core
import SwiftUI

struct BatterySettingsView: View {
    @ObservedObject var viewModel: SettingsTabViewModel
    @FocusState private var focused
    @State private var isEditingCapacity = false

    var body: some View {
        Form {
            NavigationLink("Minimum charge levels") {
                BatterySOCSettingsView(networking: viewModel.networking,
                                       config: viewModel.config,
                                       onSOCchange: {})
            }.accessibilityIdentifier("minimum charge levels")

            NavigationLink {
                DeviceSettingItemView(item: .maxSoc, networking: viewModel.networking, configManager: viewModel.config)
            } label: {
                Text("Maximum charge level")
            }

            NavigationLink("Charge times") {
                BatteryChargeScheduleSettingsView(networking: viewModel.networking, config: viewModel.config)
            }.accessibilityIdentifier("charge schedule")
            
            NavigationLink("Heating schedule") {
                BatteryHeatingScheduleSettingsView(networking: viewModel.networking, config: viewModel.config)
            }

            Section(
                content: {
                    HStack(alignment: .top) {
                        Text("Storage capacity")
                        Spacer()
                        HStack(alignment: .top) {
                            if isEditingCapacity {
                                VStack(alignment: .trailing) {
                                    TextField("Capacity", text: $viewModel.batteryCapacity)
                                        .multilineTextAlignment(.trailing)
                                        .keyboardType(.numberPad)
                                        .focused($focused)

                                    HStack {
                                        Button("OK") {
                                            viewModel.saveBatteryCapacity()
                                            isEditingCapacity = false
                                            focused = false
                                        }.buttonStyle(.bordered)

                                        Button("Cancel") {
                                            viewModel.revertBatteryCapacityEdits()
                                            isEditingCapacity = false
                                            focused = false
                                        }.buttonStyle(.bordered)
                                    }
                                }
                            } else {
                                Text(viewModel.batteryCapacity)
                                    .onTapGesture {
                                        focused = true
                                        isEditingCapacity = true
                                    }
                            }
                            Text(" Wh")
                        }
                    }
                },
                header: { Text("Display Options") },
                footer: {
                    VStack {
                        Button("Recalculate capacity", action: {
                            viewModel.recalculateBatteryCapacity()
                        })
                        .buttonStyle(.borderless)
                        .padding(.bottom, 4)

                        Text("Calculated as ") +
                        Text("capacity = residual / (Min SOC / 100)").italic() +
                        Text(" where residual is estimated by your installation and may not be accurate. Tap the capacity above to enter a manual value for the size of your battery if the value shown is incorrect.")
                    }
                }
            ).alert("Invalid Battery Capacity", isPresented: $viewModel.showAlert, actions: {
                Button("OK") {}
            }, message: {
                Text("Amount entered must be greater than 0")
            })
            .alert("Recalculated", isPresented: $viewModel.showRecalculationAlert, actions: {
                Button("OK") {}
            }, message: {
                Text("Battery capacity recalculated")
            })

            Section {
                Toggle(isOn: $viewModel.showBatteryEstimate) {
                    Text("Show battery full/empty estimate")
                }
            } footer: {
                Text("Empty/full battery durations are estimates based on calculated capacity, assume that solar conditions and battery charge rates remain constant.")
            }

            Section {
                Toggle(isOn: $viewModel.showUsableBatteryOnly) {
                    Text("Show usable battery only")
                }
            } footer: {
                Text("show_usable_battery_description")
            }

            Section {
                Toggle(isOn: $viewModel.showBatteryTemperature) {
                    Text("Show battery (BMS) temperature")
                }
            } footer: {
                Text("show_battery_bms_temperature_description")
            }
            
            Section {
                HStack {
                    Text("Display battery stack").padding(.trailing)
                    Spacer()
                    Picker("Display battery stack", selection: $viewModel.batteryTemperatureDisplayMode) {
                        Text("Auto").tag(BatteryTemperatureDisplayMode.automatic)
                        Text("1").tag(BatteryTemperatureDisplayMode.battery1)
                        Text("2").tag(BatteryTemperatureDisplayMode.battery2)
                    }.pickerStyle(.segmented)
                }.disabled(!viewModel.showBatteryTemperature)
            } footer: {
                Text(batteryDisplayModeText)
            }

            Section {
                Toggle(isOn: $viewModel.showBatterySOCOnDailyStats) {
                    Text("Show battery SOC on daily stats")
                }
            } footer: {
                Text("show_battery_soc_on_daily_stats")
            }

            NavigationLink {
                BatteryFirmwareVersionsView(network: viewModel.networking, config: viewModel.config)
            } label: {
                Text("Battery versions")
            }

        }
        .navigationTitle(.battery)
    }

    private var batteryDisplayModeText: String {
        switch viewModel.batteryTemperatureDisplayMode {
        case .automatic:
            String(key: .batteryTemperatureDisplayMode_automatic)
        case .battery1:
            String(key: .batteryTemperatureDisplayMode_batteryN, arguments: "1")
        case .battery2:
            String(key: .batteryTemperatureDisplayMode_batteryN, arguments: "2")
        }
    }
}

#if DEBUG
struct BatterySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BatterySettingsView(viewModel: SettingsTabViewModel(
                userManager: .preview(),
                config: ConfigManager.preview(),
                networking: NetworkService.preview()
            ))
        }
    }
}
#endif
