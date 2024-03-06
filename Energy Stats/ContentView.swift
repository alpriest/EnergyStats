//
//  ContentView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import Energy_Stats_Core
import SwiftUI

struct ContentView: View {
    @ObservedObject var loginManager: UserManager
    let network: Networking
    let configManager: ConfigManager
    let solarForecastProvider: SolarForecastProviding
    @State private var state = LoadState.inactive

    var body: some View {
        if loginManager.isLoggedIn {
            TabbedView(networking: network, userManager: loginManager, configManager: configManager, solarForecastProvider: solarForecastProvider)
                .task { await network.fetchErrorMessages() }
        } else {
            APIKeyLoginView(userManager: loginManager)
        }
    }
}

#if DEBUG
#Preview {
    ContentView(
        loginManager: .preview(),
        network: DemoNetworking(),
        configManager: PreviewConfigManager(),
        solarForecastProvider: { DemoSolcast() }
    )
}
#endif
