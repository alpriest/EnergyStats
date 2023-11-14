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
    let networking: Networking
    let userManager: UserManager
    @StateObject var settingsTabViewModel: SettingsTabViewModel

    init(networking: Networking, userManager: UserManager, configManager: ConfigManager) {
        self.networking = networking
        self.userManager = userManager
        self.configManager = configManager
        _settingsTabViewModel = .init(wrappedValue: SettingsTabViewModel(userManager: userManager, config: configManager, networking: networking))
    }

    var body: some View {
        TabView {
            PowerFlowTabView(configManager: configManager, networking: networking, userManager: userManager, appThemePublisher: configManager.appTheme)
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Power flow")
                    }
                    .accessibilityIdentifier("power_flow_tab")
                }

            StatsTabView(configManager: configManager, networking: networking, appThemePublisher: configManager.appTheme)
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

            SummaryTabView(configManager: configManager, networking: networking, appThemePublisher: configManager.appTheme)
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

            SettingsTabView(viewModel: settingsTabViewModel, configManager: configManager, networking: networking)
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
    TabbedView(networking: DemoNetworking(), userManager: .preview(), configManager: PreviewConfigManager())
}
#endif
