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
            }, footer: {
                Text("These values are automatically calculated from your installation. If your battery is below min SOC then the total capacity calculation will be incorrect.")
            })

            Section(content: {
                VStack {
                    Text("You are logged in as \(userManager.getUsername() ?? "")")
                    Button("logout") {
                        userManager.logout()
                    }.buttonStyle(.bordered)
                }.frame(maxWidth: .infinity)
            }, footer: {
                VStack {
                    HStack {
                        Image(systemName: "envelope")
                        Button("Get in touch with us") {
                            UIApplication.shared.open(URL(string: "mailto:energystatsapp@gmail.com")!)
                        }
                    }
                }
                .padding(.top, 88)
                .frame(maxWidth: .infinity)
            })
        }
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView(userManager: UserManager(networking: MockNetworking(), store: KeychainStore(), configManager: MockConfigManager()), configManager: MockConfigManager())
    }
}
