//
//  TabbedView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Energy_Stats_Core
import SwiftUI

struct TabbedView: View {
    let configManager: ConfigManager
    let networking: FoxESSNetworking
    let userManager: UserManager
    let solarForecastProvider: SolarForecastProviding
    @StateObject var settingsTabViewModel: SettingsTabViewModel

    init(networking: FoxESSNetworking, userManager: UserManager, configManager: ConfigManager, solarForecastProvider: @escaping SolarForecastProviding) {
        self.networking = networking
        self.userManager = userManager
        self.configManager = configManager
        self.solarForecastProvider = solarForecastProvider
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

            StatsTabView(configManager: configManager, networking: networking, appSettingsPublisher: configManager.appSettingsPublisher)
                .tabItem {
                    VStack {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Stats")
                    }
                    .accessibilityIdentifier("stats_tab")
                }

            ParametersGraphTabView(configManager: configManager, networking: networking)
                .tabItem {
                    VStack {
                        Image(systemName: "chart.xyaxis.line")
                        Text("Parameters")
                    }
                    .accessibilityIdentifier("parameters_tab")
                }

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

            SettingsTabView(viewModel: settingsTabViewModel, configManager: configManager, networking: networking, solarService: solarForecastProvider)
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
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
#Preview {
    TabbedView(networking: DemoNetworking(),
               userManager: .preview(),
               configManager: PreviewConfigManager(),
               solarForecastProvider: { DemoSolcast() })
}
#endif
