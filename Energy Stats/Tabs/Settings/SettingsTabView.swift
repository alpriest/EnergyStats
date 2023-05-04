//
//  SettingsTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import Energy_Stats_Core
import SwiftUI

struct SettingsTabView: View {
    @ObservedObject var viewModel: SettingsTabViewModel
    let configManager: ConfigManaging

    var body: some View {
        NavigationView {
            Form {
                InverterChoiceView(viewModel: viewModel)
                InverterFirmwareVersionsView(config: configManager)
                BatterySettingsView(viewModel: viewModel)

                Section(
                    content: {
                        Toggle(isOn: $viewModel.showColouredLines) {
                            Text("Show coloured flow lines")
                        }

                        Toggle(isOn: $viewModel.showBatteryTemperature) {
                            Text("Show battery temperature")
                        }

                        Toggle(isOn: $viewModel.showBatteryEstimate) {
                            Text("Show battery full/empty estimate")
                        }

                        Toggle(isOn: $viewModel.showUsableBatteryOnly) {
                            Text("Show usable battery only")
                        }

                        Toggle(isOn: $viewModel.showSunnyBackground) {
                            Text("Show sunshine background")
                        }

                        HStack {
                            Text("Decimal places").padding(.trailing)
                            Spacer()
                            Picker("Decimal places", selection: $viewModel.decimalPlaces) {
                                Text("2").tag(2)
                                Text("3").tag(3)
                            }.pickerStyle(.segmented)
                        }

                        Toggle(isOn: $viewModel.showInW) {
                            Text("Show values in Watts")
                        }
                    },
                    header: {
                        Text("Display")
                    },
                    footer: {
                        Text("'Show usable battery' deducts the Min SOC amount from the battery charge level and percentage. Due to inaccuracies in the way battery levels are measured this may result in occasionally showing a negative amount remaining.")
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
                        Text("FoxESS Cloud data is updated every 5 minutes. 'Auto' attempts to synchronise data fetches just after the data is uploaded from your inverter to minimise server load.")
                    })

                Section {
                    NavigationLink("Debug") { DebugDataView() }
                }

                Section(
                    content: {
                        VStack {
                            Text("You are logged in as \(viewModel.username)")
                            Button("logout") {
                                viewModel.logout()
                            }.buttonStyle(.bordered)
                        }.frame(maxWidth: .infinity)
                    }, footer: {
                        HStack {
                            Button(action: {
                                let url = URL(string: "itms-apps://itunes.apple.com/app/id1644492526?action=write-review")!
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }, label: {
                                Image(systemName: "medal")
                                Text("Rate this app")
                                    .multilineTextAlignment(.center)
                            })

                            Spacer()

                            HStack {
                                Button(action: {
                                    UIApplication.shared.open(URL(string: "mailto:energystatsapp@gmail.com")!)
                                }, label: {
                                    Image(systemName: "envelope")
                                    Text("Get in touch")
                                })
                            }
                        }
                        .padding(.top, 88)
                        .padding(.bottom, 44)
                        .frame(maxWidth: .infinity)
                    })
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView(
            viewModel: SettingsTabViewModel(
                userManager: .preview(),
                config: PreviewConfigManager()),
            configManager: PreviewConfigManager())
    }
}
