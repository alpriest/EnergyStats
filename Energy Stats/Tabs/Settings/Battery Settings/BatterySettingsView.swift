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
                BatterySOCSettingsView(networking: viewModel.networking, config: viewModel.config, onSOCchange: { viewModel.recalculateBatteryCapacity() })
            }.accessibilityIdentifier("minimum charge levels")

            NavigationLink("Charge times") {
                BatteryChargeScheduleSettingsView(networking: viewModel.networking, config: viewModel.config)
            }.accessibilityIdentifier("charge schedule")

            Section(
                content: {
                    HStack(alignment: .top) {
                        Text("Capacity")
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
                }, footer: {
                    VStack(alignment: .leading) {
                        Button("Recalculate capacity", action: {
                            viewModel.recalculateBatteryCapacity()
                        })
                        .buttonStyle(.borderless)
                        .padding(.bottom, 4)

                        Text("Calculated as ") +
                            Text("capacity = residual / (Min SOC / 100)").italic() +
                            Text(" where residual is estimated by your installation and may not be accurate. Tap the capacity above to enter a manual value.")
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

            Section(content: {
                Toggle(isOn: $viewModel.showUsableBatteryOnly) {
                    Text("Show usable battery only")
                }
            }, footer: {
                Text("show_usable_battery_description")
            })

            Section {
                Toggle(isOn: $viewModel.showBatteryTemperature) {
                    Text("Show battery temperature")
                }
            }
        }
        .navigationTitle("Battery")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct BatterySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BatterySettingsView(viewModel: SettingsTabViewModel(
                userManager: .preview(),
                config: PreviewConfigManager(),
                networking: DemoNetworking()
            ))
        }
    }
}
#endif
