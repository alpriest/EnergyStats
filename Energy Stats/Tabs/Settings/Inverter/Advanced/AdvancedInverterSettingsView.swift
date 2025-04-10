//
//  AdvancedInverterSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/04/2025.
//

import Energy_Stats_Core
import SwiftUI

struct AdvancedInverterSettingsView: View {
    let config: ConfigManaging
    let networking: Networking

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 22) {
                    Text("These settings control the behaviour of the inverter. Please be cautious and only change them if you know what you are doing.")

                    Text("Energy Stats cannot be held responsible for any damage caused by changing these settings.")
                }
            }

            Section {
                NavigationLink {
                    DeviceSettingItemView(item: .exportLimit, networking: networking, config: config)
                } label: {
                    Text("Export limit")
                }

                NavigationLink {
                    DeviceSettingItemView(item: .maxSoc, networking: networking, config: config)
                } label: {
                    Text("Max SOC")
                }
            }
        }
        .navigationTitle("Advanced Inverter Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        AdvancedInverterSettingsView(config: ConfigManager.preview(), networking: NetworkService.preview())
    }
}
