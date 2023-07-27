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
    @State private var tabView: BatteryChargeTab = .soc
    private let networking: Networking
    private let config: ConfigManaging
    private let onSOCchange: () -> Void

    init(networking: Networking, config: ConfigManaging, onSOCchange: @escaping () -> Void) {
        self.networking = networking
        self.config = config
        self.onSOCchange = onSOCchange
    }

    var body: some View {
        Form {
            Section {
                Picker(selection: $tabView) {
                    Text("Min SoC")
                        .tag(BatteryChargeTab.soc)
                    Text("Force Charge")
                        .tag(BatteryChargeTab.forceCharge)
                } label: {
                    Text("Group")
                }
                .pickerStyle(.segmented)
            }

            Group {
                switch tabView {
                case .soc:
                    BatterySOCSettingsView(networking: networking, config: config, onSOCchange: onSOCchange)
                case .forceCharge:
                    BatteryForceChargeSettingsView(networking: networking, config: config)
                }
            }
        }
    }
}

struct BatteryChargeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryChargeSettingsView(networking: DemoNetworking(),
                                  config: ConfigManager(networking: DemoNetworking(), config: MockConfig()),
                                  onSOCchange: { })
    }
}
