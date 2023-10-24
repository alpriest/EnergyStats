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
    @State private var state = LoadState.inactive

    var body: some View {
        if loginManager.isLoggedIn {
            TabbedView(networking: network, userManager: loginManager, configManager: configManager)
        } else {
            LoginView(userManager: loginManager)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            loginManager: .preview(),
            network: DemoNetworking(),
            configManager: PreviewConfigManager()
        )
    }
}
#endif
