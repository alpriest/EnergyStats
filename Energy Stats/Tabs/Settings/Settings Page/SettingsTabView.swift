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
    let networking: Networking

    var body: some View {
        NavigationView {
            Form {
                NavigationLink {
                    InverterSettingsView(networking: networking,
                                         configManager: configManager,
                                         firmwareVersion: viewModel.firmwareVersions,
                                         showInverterTemperature: $viewModel.showInverterTemperature)
                } label: {
                    Text("Inverter")
                }

                if viewModel.hasBattery {
                    NavigationLink {
                        BatterySettingsView(viewModel: viewModel)
                    } label: {
                        Text("Battery")
                            .accessibilityIdentifier("battery")
                    }
                }

                NavigationLink {
                    DataLoggersView(networking: networking)
                } label: {
                    Text("Datalogger")
                }

                Section(
                    content: {
                        Toggle(isOn: $viewModel.showColouredLines) {
                            Text("Show coloured flow lines")
                        }

                        Toggle(isOn: $viewModel.showTotalYield) {
                            Text("Show total yield")
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
                    })

                Section {
                    Toggle(isOn: $viewModel.showEarnings) {
                        Text("Show estimated earnings")
                    }
                } footer: {
                    Text("Shows earnings today, this month, this year, and all-time based on a crude calculation of feed-in ｘ price as configured on FoxESS cloud.")
                }

                SelfSufficiencySettingsView(mode: $viewModel.selfSufficiencyEstimateMode)

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
                    NavigationLink("FoxESS Cloud Status") { WebView(url: URL(string: "https://monitor.foxesscommunity.com/status/foxess")!) }
                    Button {
                        let url = URL(string: "https://www.facebook.com/groups/foxessownersgroup")!
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } label: {
                        NavigationLink("Facebook group", destination: EmptyView())
                    }.buttonStyle(.plain)
                    NavigationLink("Debug") { DebugDataView(networking: networking, configManager: configManager) }
                    NavigationLink("FAQ") { FAQView() }
                }

                SettingsFooterView(username: viewModel.username, onLogout: viewModel.logout, appVersion: viewModel.appVersion)
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView(
            viewModel: SettingsTabViewModel(
                userManager: .preview(),
                config: PreviewConfigManager(),
                networking: DemoNetworking()),
            configManager: PreviewConfigManager(),
            networking: DemoNetworking())
    }
}
#endif
