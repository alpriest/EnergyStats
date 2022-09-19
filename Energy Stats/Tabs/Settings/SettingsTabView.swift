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
                        Text("kWh capacity")
                        TextField("kWh", text: $capacity)
                            .keyboardType(.numberPad)
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
        }
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView(credentials: KeychainStore())
    }
}
