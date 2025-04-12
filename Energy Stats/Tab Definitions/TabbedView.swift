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
    @StateObject var parametersGraphTabViewModel: ParametersGraphTabViewModel

    init(networking: Networking, userManager: UserManager, configManager: ConfigManaging, solarForecastProvider: @escaping SolarForecastProviding, templateStore: TemplateStoring) {
        self.networking = networking
        self.userManager = userManager
        self.configManager = configManager
        self.solarForecastProvider = solarForecastProvider
        self.templateStore = templateStore
        _settingsTabViewModel = .init(wrappedValue: SettingsTabViewModel(userManager: userManager, config: configManager, networking: networking))
        _parametersGraphTabViewModel = .init(wrappedValue: ParametersGraphTabViewModel(networking: networking, configManager: configManager, solarForecastProvider: solarForecastProvider))
    }

    var body: some View {
        TabView {
            PowerFlowTabView(
                configManager: configManager,
                networking: networking,
                userManager: userManager,
                appSettingsPublisher: configManager.appSettingsPublisher,
                templateStore: templateStore
            )
            .tabItem {
                PowerFlowTabItem()
            }
            .toolbarBackground(.visible, for: .tabBar)

            StatsTabView(configManager: configManager, networking: networking, appSettingsPublisher: configManager.appSettingsPublisher)
                .tabItem {
                    StatsTabItem()
                }
                .toolbarBackground(.visible, for: .tabBar)

            ParametersGraphTabView(configManager: configManager, viewModel: parametersGraphTabViewModel)
                .tabItem {
                    ParametersTabItem()
                }
                .toolbarBackground(.visible, for: .tabBar)

            SummaryTabView(configManager: configManager, networking: networking, appSettingsPublisher: configManager.appSettingsPublisher, solarForecastProvider: solarForecastProvider)
                .tabItem {
                    SummaryTabItem()
                }
                .toolbarBackground(.visible, for: .tabBar)

            SettingsTabView(viewModel: settingsTabViewModel, configManager: configManager, networking: networking, solarService: solarForecastProvider, templateStore: templateStore)
                .tabItem {
                    SettingsTabItem()
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
        .environmentObject(VersionChecker(urlSession: URLSession.shared))
}
#endif
