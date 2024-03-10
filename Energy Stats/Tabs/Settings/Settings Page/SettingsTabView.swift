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
    let solarService: SolarForecastProviding
    @EnvironmentObject var versionChecker: VersionChecker

    var body: some View {
        NavigationView {
            Form {
                Section {
                    if versionChecker.upgradeAvailable {
                        VStack {
                            Text("App Version \(versionChecker.latestVersion) is available")
                            Button {
                                UIApplication.shared.open(versionChecker.appStoreUrl)
                            } label: {
                                Text("Upgrade now")
                            }
                        }.frame(maxWidth: .infinity)
                    }
                }

                if let powerStation = viewModel.powerStation {
                    NavigationLink {
                        PowerStationSettingsView(station: powerStation)
                    } label: {
                        Text("Power station")
                    }
                }

                NavigationLink {
                    InverterSettingsView(networking: networking,
                                         configManager: configManager,
                                         showInverterTemperature: $viewModel.showInverterTemperature,
                                         showInverterIcon: $viewModel.showInverterIcon,
                                         shouldInvertCT2: $viewModel.shouldInvertCT2,
                                         showInverterStationName: $viewModel.showInverterStationName,
                                         shouldCombineCT2WithPVPower: $viewModel.shouldCombineCT2WithPVPower,
                                         showInverterTypeName: $viewModel.showInverterTypeName,
                                         shouldCombineCT2WithLoadsPower: $viewModel.shouldCombineCT2WithLoadsPower)
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

                DisplaySettingsView(viewModel: viewModel, configManager: configManager, solarService: solarService)

                Section(
                    content: {
                        Picker("Data Refresh frequency", selection: $viewModel.refreshFrequency) {
                            Text("1 min").tag(RefreshFrequency.ONE_MINUTE)
                            Text("5 mins").tag(RefreshFrequency.FIVE_MINUTES)
                            Text("Auto").tag(RefreshFrequency.AUTO)
                        }
                        .pickerStyle(.segmented)
                    }, header: {
                        Text("settings.dataRefreshFrequencyHeader")
                    }, footer: {
                        Text("FoxESS Cloud data is updated every 5 minutes. 'Auto' attempts to synchronise data fetches just after the data is uploaded from your inverter to minimise server load.")
                    })

                Section {
                    NavigationLink("FoxESS Cloud Status") { WebView(url: URL(string: "https://monitor.foxesscommunity.com/status/foxess")!) }

                    ExternalWebNavigationLink(url: "https://www.foxesscommunity.com", title: .foxessCommunity)
                    ExternalWebNavigationLink(url: "https://www.facebook.com/groups/foxessownersgroup", title: .facebookGroup)

                    NavigationLink("settings.faq") { FAQView() }
                    NavigationLink("settings.debug") { DebugDataView(networking: networking, configManager: configManager) }
                    NavigationLink("Edit API Key") { ConfigureAPIKeyView() }
                }

                SettingsFooterView(onLogout: viewModel.logout, appVersion: viewModel.appVersion)
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
            networking: DemoNetworking(),
            solarService: { DemoSolcast() })
            .environmentObject(VersionChecker())
    }
}
#endif
