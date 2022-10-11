//
//  SettingsTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import SwiftUI

struct SettingsTabView: View {
    let userManager: UserManager
    private let configManager: ConfigManager

    init(userManager: UserManager, configManager: ConfigManager) {
        self.userManager = userManager
        self.configManager = configManager
    }

    var body: some View {
        Form {
            Section(content: {
                HStack {
                    Text("Min SOC")
                    Spacer()
                    Text(configManager.minSOC, format: .percent)
                }

                HStack {
                    Text("Capacity")
                    Spacer()
                    Text(configManager.batteryCapacity, format: .number)
                    Text("kW")
                }
            }, header: {
                Text("Battery")
            })

            Section {
                VStack {
                    Text("You are logged in as \(userManager.getUsername() ?? "")")
                    Button("logout") {
                        userManager.logout()
                    }.buttonStyle(.bordered)
                }.frame(maxWidth: .infinity)
            }
        }
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView(userManager: UserManager(networking: MockNetworking(), store: KeychainStore(), configManager: MockConfigManager()), configManager: MockConfigManager())
    }
}
