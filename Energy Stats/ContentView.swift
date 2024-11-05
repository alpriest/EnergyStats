//
//  ContentView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import Energy_Stats_Core
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    let network: Networking
    let configManager: ConfigManaging
    let solarForecastProvider: SolarForecastProviding
    let templateStore: TemplateStoring
    @State private var state = LoadState.inactive

    var body: some View {
        Group {
            if userManager.isLoggedIn {
                Group {
#if targetEnvironment(macCatalyst)
                    LeftTabbedView(networking: network, userManager: userManager, configManager: configManager, solarForecastProvider: solarForecastProvider, templateStore: templateStore)
#else
                    ZStack {
                        TabbedView(networking: network, userManager: userManager, configManager: configManager, solarForecastProvider: solarForecastProvider, templateStore: templateStore)

                        BannerAlertView()
                    }
#endif
                }
                .task { await network.fetchErrorMessages() }

            } else {
                WelcomeView(userManager: userManager)
            }
        }
        .preferredColorScheme(colorScheme())
    }

    private func colorScheme() -> ColorScheme? {
        switch configManager.colorScheme {
        case .dark:
            .dark
        case .light:
            .light
        default:
            nil
        }
    }
}

#if DEBUG
#Preview {
    ContentView(
        network: NetworkService.preview(),
        configManager: ConfigManager.preview(),
        solarForecastProvider: { DemoSolcast() },
        templateStore: TemplateStore.preview()
    )
    .environmentObject(UserManager.preview())
}
#endif
