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
    let templateStore: TemplateStoring
    @EnvironmentObject var versionChecker: VersionChecker

    var body: some View {
        NavigationStack {
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

                if let powerStation = configManager.powerStationDetail {
                    NavigationLink {
                        PowerStationSettingsView(station: powerStation, configManager: configManager)
                    } label: {
                        Text("Power Station")
                    }
                }

                NavigationLink {
                    InverterSettingsView(networking: networking,
                                         configManager: configManager,
                                         templateStore: templateStore,
                                         showInverterTemperature: $viewModel.showInverterTemperature,
                                         showInverterIcon: $viewModel.showInverterIcon,
                                         shouldInvertCT2: $viewModel.shouldInvertCT2,
                                         showInverterStationName: $viewModel.showInverterStationName,
                                         shouldCombineCT2WithPVPower: $viewModel.shouldCombineCT2WithPVPower,
                                         showInverterTypeName: $viewModel.showInverterTypeName,
                                         showInverterScheduleQuickLink: $viewModel.showInverterScheduleQuickLink,
                                         showCT2ValueAsString: $viewModel.showCT2ValueAsString)
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

                Section {
                    NavigationLink("FoxESS Cloud Status") { WebView(url: URL(string: "https://monitor.foxesscommunity.com/status/foxess")!) }

                    ExternalWebNavigationLink(url: "https://www.foxesscommunity.com", title: .foxessCommunity)
                    ExternalWebNavigationLink(url: "https://www.facebook.com/groups/foxessownersgroup", title: .facebookGroup)

                    NavigationLink("settings.faq") { FAQView() }
                    NavigationLink("settings.debug") { DebugDataView(networking: networking, configManager: configManager) }
                    NavigationLink("Edit API Key") { ConfigureAPIKeyView() }
                }

                SettingsFooterView(
                    configManager: configManager,
                    onLogout: {
                        Task {
                            await viewModel.logout()
                        }
                    },
                    appVersion: viewModel.appVersion)
            }
            .navigationTitle(.settings)
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
                config: ConfigManager.preview(),
                networking: NetworkService.preview()
            ),
            configManager: ConfigManager.preview(),
            networking: NetworkService.preview(),
            solarService: { DemoSolcast() },
            templateStore: TemplateStore.preview()
        )
        .environmentObject(VersionChecker())
    }
}
#endif
