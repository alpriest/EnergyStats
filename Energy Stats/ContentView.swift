//
//  ContentView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import Energy_Stats_Core
import SwiftUI

struct ContentView: View {
    @ObservedObject var userManager: UserManager
    let network: Networking
    let configManager: ConfigManaging
    let solarForecastProvider: SolarForecastProviding
    let templateStore: TemplateStoring
    @State private var state = LoadState.inactive
    @EnvironmentObject var alertManager: SlowServerBannerAlertManager

    var body: some View {
        if userManager.isLoggedIn {
            ZStack {
                TabbedView(networking: network, userManager: userManager, configManager: configManager, solarForecastProvider: solarForecastProvider, templateStore: templateStore)

                if alertManager.isShowingAlert {
                    SlowServerMessageView()
                }
            }
            .task { await network.fetchErrorMessages() }
        } else {
            APIKeyLoginView(userManager: userManager)
        }
    }
}

#if DEBUG
#Preview {
    ContentView(
        userManager: .preview(),
        network: NetworkService.preview(),
        configManager: ConfigManager.preview(),
        solarForecastProvider: { DemoSolcast() },
        templateStore: TemplateStore.preview()
    )
}
#endif
