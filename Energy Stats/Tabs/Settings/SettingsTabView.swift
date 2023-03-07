//
//  SettingsTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import SwiftUI

enum RefreshFrequency: Int {
    case AUTO = 0
    case ONE_MINUTE = 1
    case FIVE_MINUTES = 5
}

struct SettingsTabView: View {
    @ObservedObject var viewModel: SettingsTabViewModel
    @State private var isEditingCapacity = false
    @FocusState private var focused

    var body: some View {
        Form {
            Section(
                content: {
                    HStack {
                        Text("Min SOC")
                        Spacer()
                        Text(viewModel.minSOC, format: .percent)
                    }

                    HStack(alignment: .top) {
                        Text("Capacity")
                        Spacer()
                        HStack(alignment: .top) {
                            if isEditingCapacity {
                                VStack(alignment: .trailing) {
                                    TextField("Capacity", text: $viewModel.batteryCapacity)
                                        .multilineTextAlignment(.trailing)
                                        .focused($focused)

                                    HStack {
                                        Button("OK") {
                                            isEditingCapacity = false
                                            focused = false
                                        }.buttonStyle(.bordered)
                                        Button("Cancel") {
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
                            Text(" kW")
                        }
                    }
                }, header: {
                    Text("Battery")
                }, footer: {
                    Text("Calculated as ") +
                        Text("residual / (Min SOC / 100)").italic() +
                        Text(" where residual is estimated by your installation and may not be accurate. Tap the capacity above to enter a manual value.\n\n") +
                        Text("Empty/full battery durations are estimates based on calculated capacity, assume that solar conditions and battery charge rates remain constant.")
                })

            Section(
                content: {
                    Toggle(isOn: $viewModel.showColouredLines) {
                        Text("Show coloured flow lines")
                    }

                    Toggle(isOn: $viewModel.showBatteryTemperature) {
                        Text("Show battery temperature")
                    }

                    Toggle(isOn: $viewModel.showSunnyBackground) {
                        Text("Show sunny background")
                    }

                    HStack {
                        Text("Decimal places").padding(.trailing)
                        Spacer()
                        Picker("Decimal places", selection: $viewModel.decimalPlaces) {
                            Text("2").tag(2)
                            Text("3").tag(3)
                        }.pickerStyle(.segmented)
                    }
                },
                header: {
                    Text("Display")
                })

            Section(
                content: {
                    Picker("Refresh frequency", selection: $viewModel.refreshFrequency) {
                        Text("1 min").tag(RefreshFrequency.ONE_MINUTE)
                        Text("5 mins").tag(RefreshFrequency.FIVE_MINUTES)
                        Text("Auto").tag(RefreshFrequency.AUTO)
                    }
                    .pickerStyle(.segmented)
                }, header: {
                    Text("Refresh frequency")
                }, footer: {
                    Text("FoxESS Cloud data is updated every 5 minutes. Auto attempts to synchronise fetches just after the data feed uploads to minimise server load.")
                })

            Section(
                content: {
                    VStack {
                        Text("You are logged in as \(viewModel.username)")
                        Button("logout") {
                            viewModel.logout()
                        }.buttonStyle(.bordered)
                    }.frame(maxWidth: .infinity)
                }, footer: {
                    VStack {
                        HStack {
                            Image(systemName: "envelope")
                            Button("Get in touch with us") {
                                UIApplication.shared.open(URL(string: "mailto:energystatsapp@gmail.com")!)
                            }
                        }
                    }
                    .padding(.top, 88)
                    .frame(maxWidth: .infinity)
                })
        }
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView(viewModel: SettingsTabViewModel(
            userManager: UserManager(networking: DemoNetworking(), store: KeychainStore(), configManager: MockConfigManager()),
            config: MockConfigManager())
        )
    }
}
