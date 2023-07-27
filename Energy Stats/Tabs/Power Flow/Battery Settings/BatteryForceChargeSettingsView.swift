//
//  BatteryForceChargeSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import Energy_Stats_Core
import SwiftUI

struct BatteryForceChargeSettingsView: View {
    @StateObject var viewModel: BatteryForceChargeSettingsViewModel

    init(networking: Networking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: BatteryForceChargeSettingsViewModel(networking: networking, config: config))
    }

    var body: some View {
        Form {
            BatteryTimePeriodView(timePeriod: $viewModel.timePeriod1, title: "Force charge period 1")
            BatteryTimePeriodView(timePeriod: $viewModel.timePeriod2, title: "Force charge period 2")

            Section(content: {}, footer: {
                VStack {
                    Button(action: { viewModel.save() }, label: {
                        Text("Save")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    })
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.valid)
                }
            })
        }
        .loadable($viewModel.state, retry: { viewModel.load() })
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
