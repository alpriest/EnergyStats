//
//  LeftTabbedView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 23/09/2024.
//

import Energy_Stats_Core
import SwiftUI

enum SelectedTab {
    case PowerFlow
    case Parameters
    case Stats
    case Summary
    case Settings
}

struct LeftTabbedView: View {
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
        NavigationSplitView(
            sidebar: {
                List {
                    NavigationLink {
                        PowerFlowTabView(
                            configManager: configManager,
                            networking: networking,
                            userManager: userManager,
                            appSettingsPublisher: configManager.appSettingsPublisher,
                            templateStore: templateStore
                        )
                    } label: {
                        PowerFlowTabItem()
                    }

                    NavigationLink {
                        StatsTabView(
                            configManager: configManager,
                            networking: networking,
                            appSettingsPublisher: configManager.appSettingsPublisher
                        )
                    } label: {
                        StatsTabItem()
                    }

                    NavigationLink {
                        ParametersGraphTabView(configManager: configManager, viewModel: parametersGraphTabViewModel)
                    } label: {
                        ParametersTabItem()
                    }

                    NavigationLink {
                        SummaryTabView(configManager: configManager, networking: networking, appSettingsPublisher: configManager.appSettingsPublisher, solarForecastProvider: solarForecastProvider)
                    } label: {
                        SummaryTabItem()
                    }

                    NavigationLink {
                        SettingsTabView(viewModel: settingsTabViewModel, configManager: configManager, networking: networking, solarService: solarForecastProvider, templateStore: templateStore)
                    } label: {
                        SettingsTabItem()
                    }
                }
            },
            detail: {
                PowerFlowTabView(
                    configManager: configManager,
                    networking: networking,
                    userManager: userManager,
                    appSettingsPublisher: configManager.appSettingsPublisher,
                    templateStore: templateStore
                )
            }
        )
    }
}

#Preview {
    LeftTabbedView(networking: NetworkService.preview(),
                   userManager: .preview(),
                   configManager: ConfigManager.preview(),
                   solarForecastProvider: { DemoSolcast() },
                   templateStore: TemplateStore.preview())
        .environmentObject(VersionChecker(urlSession: URLSession.shared))
}
