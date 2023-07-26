//
//  BatteryForceChargeSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import Energy_Stats_Core
import SwiftUI

struct BatteryForceChargeSettingsView: View {
    @State private var timePeriod1: ChargeTimePeriod = .init(enabled: false)
    @State private var timePeriod2: ChargeTimePeriod = .init(enabled: false)
    @State private var hasLoaded = false
    let networking: Networking
    let config: ConfigManaging

    var body: some View {
        Group {
            if hasLoaded {
                BatteryTimePeriodView(timePeriod: $timePeriod1, title: "Force charge period 1")
                BatteryTimePeriodView(timePeriod: $timePeriod2, title: "Force charge period 2")

                Section(content: {}, footer: {
                    VStack {
                        Button(action: {}, label: {
                            Text("Save")
                                .frame(minWidth: 0, maxWidth: .infinity)
                        })
                        .buttonStyle(.borderedProminent)
                        .disabled(!timePeriod1.valid || !timePeriod2.valid)
                    }
                })
            } else {
                ProgressView()
            }
        }.onAppear {
            guard !hasLoaded else { return }
        }
    }
}

struct BatteryForceChargeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            BatteryForceChargeSettingsView(networking: DemoNetworking(),
                                           config: ConfigManager(networking: DemoNetworking(), config: MockConfig()))
        }
    }
}
