//
//  TabbedView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Energy_Stats_Core
import SwiftUI

struct TabbedView: View {
    let configManager: ConfigManaging
    let networking: Networking
    let userManager: UserManager
    let solarForecastProvider: SolarForecastProviding
    let templateStore: TemplateStoring
    @StateObject var settingsTabViewModel: SettingsTabViewModel

    init(networking: Networking, userManager: UserManager, configManager: ConfigManaging, solarForecastProvider: @escaping SolarForecastProviding, templateStore: TemplateStoring) {
        self.networking = networking
        self.userManager = userManager
        self.configManager = configManager
        self.solarForecastProvider = solarForecastProvider
        self.templateStore = templateStore
        _settingsTabViewModel = .init(wrappedValue: SettingsTabViewModel(userManager: userManager, config: configManager, networking: networking))
    }

    var body: some View {
        TabView {
            PowerFlowTabView(configManager: configManager, networking: networking, userManager: userManager, appSettingsPublisher: configManager.appSettingsPublisher)
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Power flow")
                    }
                    .accessibilityIdentifier("power_flow_tab")
                }
                .toolbarBackground(.visible, for: .tabBar)

            StatsTabView(configManager: configManager, networking: networking, appSettingsPublisher: configManager.appSettingsPublisher)
                .tabItem {
                    VStack {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Stats")
                    }
                    .accessibilityIdentifier("stats_tab")
                }
                .toolbarBackground(.visible, for: .tabBar)

            ParametersGraphTabView(configManager: configManager, viewModel: ParametersGraphTabViewModel(networking: networking, configManager: configManager))
                .tabItem {
                    VStack {
                        Image(systemName: "chart.xyaxis.line")
                        Text("Parameters")
                    }
                    .accessibilityIdentifier("parameters_tab")
                }
                .toolbarBackground(.visible, for: .tabBar)

            SummaryTabView(configManager: configManager, networking: networking, appSettingsPublisher: configManager.appSettingsPublisher, solarForecastProvider: solarForecastProvider)
                .tabItem {
                    VStack {
                        if #available(iOS 17.0, *) {
                            Image(systemName: "book.pages")
                        } else {
                            Image(systemName: "book")
                        }
                        Text("Summary")
                    }
                    .accessibilityIdentifier("summary_tab")
                }
                .toolbarBackground(.visible, for: .tabBar)

            SettingsTabView(viewModel: settingsTabViewModel, configManager: configManager, networking: networking, solarService: solarForecastProvider, templateStore: templateStore)
                .tabItem {
                    VStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                    .accessibilityIdentifier("settings_tab")
                }
                .if(configManager.isDemoUser) {
                    $0.badge("demo")
                }
                .toolbarBackground(.visible, for: .tabBar)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
#Preview {
    TabbedView(networking: NetworkService.preview(),
               userManager: .preview(),
               configManager: ConfigManager.preview(),
               solarForecastProvider: { DemoSolcast() },
               templateStore: TemplateStore.preview())
        .environmentObject(VersionChecker())
}
#endif
