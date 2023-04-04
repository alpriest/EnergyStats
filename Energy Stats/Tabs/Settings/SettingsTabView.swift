//
//  SettingsTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import SwiftUI
import Energy_Stats_Core

struct SettingsTabView: View {
    @ObservedObject var viewModel: SettingsTabViewModel
    let configManager: ConfigManaging

    var body: some View {
        Form {
            InverterChoiceView(viewModel: viewModel, configManager: configManager)
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
                        Text("Show usable battery % only")
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
                            Button("Get in touch") {
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
        SettingsTabView(
            viewModel: SettingsTabViewModel(
                userManager: UserManager(networking: DemoNetworking(), store: KeychainStore(), configManager: PreviewConfigManager()),
                config: PreviewConfigManager()),
            configManager: PreviewConfigManager())
    }
}
