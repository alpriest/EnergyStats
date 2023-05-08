//
//  ContentView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import SwiftUI
import Energy_Stats_Core

struct ContentView: View {
    @ObservedObject var loginManager: UserManager
    let network: Networking
    let configManager: ConfigManager
    @State private var state = LoadState.active(String(key: .loading))

    func fetchConfig() {
        Task {
            do {
                if configManager.devices?.first(where: { $0.firmware == nil }) != nil {
                    try await configManager.fetchDevices()
                } else {
                    Task { try await configManager.refreshFirmwareVersions() }
                }

                Task { @MainActor in
                    state = .inactive
                }
            } catch let error as ConfigManager.NoDeviceFoundError {
                loginManager.logout()
                Task { @MainActor in
                    state = .error(error, String(key: .dataFetchError))
                }
            } catch let error {
                Task { @MainActor in
                    state = .error(error, String(key: .couldNotLogin))
                }
            }
        }
    }

    var body: some View {
        if loginManager.isLoggedIn {
            TabbedView(networking: network, userManager: loginManager, configManager: configManager)
                .loadable($state, retry: fetchConfig)
                .task { fetchConfig() }
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
