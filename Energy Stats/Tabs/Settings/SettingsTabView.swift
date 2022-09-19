//
//  SettingsTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2022.
//

import SwiftUI

struct SettingsTabView: View {
    let credentials: KeychainStore
    @State private var minSOC = 0.2
    @State private var capacity = "2600"

    var body: some View {
        VStack(spacing: 44) {
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
                        TextField("kWh", text: $capacity)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                        Text("kWh")
                    }
                }, header: {
                    Text("Battery")
                })

                Section {
                    VStack {
                        Text("You are logged in as \(credentials.getUsername() ?? "")")
                        Button("logout") {
                            credentials.logout()
                        }.buttonStyle(.bordered)
                    }.frame(maxWidth: .infinity)
                }
            }
        }.onChange(of: minSOC) { newValue in
            Config.shared.minSOC = String(describing: newValue)
        }.onChange(of: capacity) { newValue in
            Config.shared.batteryCapacity = String(describing: newValue)
        }.onAppear {
            minSOC = Config.shared.minSOC.asDouble() ?? 0.2
            capacity = Config.shared.batteryCapacity ?? "2600"
        }
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView(credentials: KeychainStore())
    }
}
