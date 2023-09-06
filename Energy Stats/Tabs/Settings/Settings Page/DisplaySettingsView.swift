//
//  DisplaySettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/09/2023.
//

import Energy_Stats_Core
import SwiftUI

struct DisplaySettingsView: View {
    @ObservedObject var viewModel: SettingsTabViewModel
    let configManager: ConfigManaging

    var body: some View {
        Section(
            content: {
                Group {
                    Toggle(isOn: $viewModel.showColouredLines) {
                        Text("Show coloured flow lines")
                    }

                    Toggle(isOn: $viewModel.showTotalYield) {
                        Text("Show total yield")
                    }

                    Toggle(isOn: $viewModel.showHomeTotalOnPowerFlow) {
                        Text("settings.showHomeTotalOnPowerflow")
                    }

                    Toggle(isOn: $viewModel.showGridTotalsOnPowerFlow) {
                        Text("settings.showGridTotalsOnPowerflow")
                    }

                    Toggle(isOn: $viewModel.showSunnyBackground) {
                        Text("Show sunshine background")
                    }
                }

                HStack {
                    Text("Decimal places").padding(.trailing)
                    Spacer()
                    Picker("Decimal places", selection: $viewModel.decimalPlaces) {
                        Text("2").tag(2)
                        Text("3").tag(3)
                    }.pickerStyle(.segmented)
                }

                Toggle(isOn: $viewModel.showInW) {
                    Text("Show values in Watts")
                }

                Toggle(isOn: $viewModel.showLastUpdateTimestamp) {
                    Text("Show last update timestamp")
                }

                NavigationLink {
                    ApproximationsSettingsView(configManager: configManager)
                } label: {
                    Text("Approximations")
                }
            },
            header: {
                Text("Display")
            })
    }
}

#if DEBUG
struct DisplaySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            DisplaySettingsView(
                viewModel: SettingsTabViewModel(
                    userManager: .preview(),
                    config: PreviewConfigManager(),
                    networking: DemoNetworking()),
                configManager: PreviewConfigManager())
        }
    }
}
#endif
