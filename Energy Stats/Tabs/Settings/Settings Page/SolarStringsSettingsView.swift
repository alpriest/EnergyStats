//
//  SolarStringsSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/02/2024.
//

import Energy_Stats_Core
import SwiftUI

struct SolarStringsSettingsView: View {
    @ObservedObject var viewModel: SettingsTabViewModel

    var body: some View {
        Section {
            Toggle(isOn: $viewModel.showSeparateStringsOnPowerFlow) {
                Text("Show PV power by strings")
            }
        } footer: {
            Text("If you have multiple sets of solar panels, e.g. front/rear of your home, this will let you see the power being generated by each set.")
        }
    }
}

#Preview {
    SolarStringsSettingsView(viewModel: SettingsTabViewModel(
        userManager: .preview(),
        config: PreviewConfigManager(),
        networking: DemoNetworking())
    )
}
