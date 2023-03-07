//
//  TabbedView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import SwiftUI

struct TabbedView: View {
    let configManager: ConfigManager
    let networking: Networking
    let userManager: UserManager
    @StateObject var summaryViewModel: PowerFlowTabViewModel
    @StateObject var graphViewModel: GraphTabViewModel

    init(networking: Networking, userManager: UserManager, configManager: ConfigManager) {
        self.networking = networking
        self.userManager = userManager
        self.configManager = configManager
        _summaryViewModel = .init(wrappedValue: PowerFlowTabViewModel(networking, configManager: configManager))
        _graphViewModel = .init(wrappedValue: GraphTabViewModel(networking, configManager: configManager))
    }

    var body: some View {
        TabView {
            PowerFlowTabView(viewModel: summaryViewModel, appTheme: configManager.appTheme)
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Power flow")
                    }
                    .accessibilityIdentifier("power_flow_tab")
                }

            GraphTabView(viewModel: graphViewModel)
                .tabItem {
                    VStack {
                        Image(systemName: "lines.measurement.horizontal")
                        Text("Graphs")
                    }
                    .accessibilityIdentifier("graph_tab")
                }

            SettingsTabView(viewModel: SettingsTabViewModel(userManager: userManager, config: configManager))
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

struct TabbedView_Previews: PreviewProvider {
    static var previews: some View {
        TabbedView(networking: DemoNetworking(), userManager: UserManager(networking: DemoNetworking(), store: KeychainStore(), configManager: MockConfigManager()), configManager: MockConfigManager())
    }
}
