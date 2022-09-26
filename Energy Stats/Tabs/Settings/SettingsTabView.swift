//
//  SettingsTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import SwiftUI

struct SettingsTabView: View {
    let userManager: UserManager
    @State private var config: Config
    @State private var minSOC = 0.2
    @State private var capacity = "2600"
    @FocusState private var minSOCIsFocused: Bool

    init(userManager: UserManager, config: Config) {
        self.userManager = userManager
        self._config = .init(wrappedValue: config)
    }

    var body: some View {
        Form {
            Section(content: {
                HStack {
                    Text("Min SOC")
                    HStack {
                        Slider(value: $minSOC, in: 0 ... 1, step: 0.1)
                        Text(minSOC, format: .percent)
                    }
                }

                HStack {
                    Text("Capacity")
                    Spacer()
                    TextField("kW", text: $capacity)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .focused($minSOCIsFocused)
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
        }.onTapGesture {
            minSOCIsFocused = false
        }.onChange(of: minSOC) { newValue in
            config.minSOC = String(describing: newValue)
        }.onChange(of: capacity) { newValue in
            config.batteryCapacity = String(describing: newValue)
        }.onAppear {
            minSOC = config.minSOC.asDouble() ?? 0.2
            capacity = config.batteryCapacity ?? "2600"
        }
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView(userManager: UserManager(networking: MockNetworking(), store: KeychainStore(), config: MockConfig()), config: MockConfig())
    }
}
