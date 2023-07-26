//
//  BatteryChargeSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import Energy_Stats_Core
import SwiftUI

enum BatteryChargeTab {
    case forceCharge
    case soc
}

struct BatteryChargeSettingsView: View {
    @State private var tabView: BatteryChargeTab = .forceCharge
    let networking: Networking
    let config: ConfigManaging

    init(networking: Networking, config: ConfigManaging) {
        self.networking = networking
        self.config = config
    }

    var body: some View {
        Form {
            Picker(selection: $tabView) {
                Text("Force Charge")
                    .tag(BatteryChargeTab.forceCharge)
                Text("SOC")
                    .tag(BatteryChargeTab.soc)
            } label: {
                Text("Group")
            }
            .pickerStyle(.segmented)

            Group {
                switch tabView {
                case .forceCharge:
                    BatteryForceChargeSettingsView(networking: networking, config: config)
                case .soc:
                    BatterySOCSettingsView(networking: networking, config: config)
                }
            }
        }
    }
}

struct BatteryChargeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryChargeSettingsView(networking: DemoNetworking(),
                                  config: ConfigManager(networking: DemoNetworking(), config: MockConfig()))
    }
}
