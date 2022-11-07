//
//  ContentView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var loginManager: UserManager
    let network: Networking
    let configManager: ConfigManager

    var body: some View {
        if loginManager.isLoggedIn {
            TabbedView(networking: network, userManager: loginManager, configManager: configManager)
        } else {
            LoginView(loginManager: loginManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            loginManager: UserManager(networking: DemoNetworking(), store: KeychainStore(), configManager: MockConfigManager()),
            network: DemoNetworking(),
            configManager: MockConfigManager()
        )
    }
}
