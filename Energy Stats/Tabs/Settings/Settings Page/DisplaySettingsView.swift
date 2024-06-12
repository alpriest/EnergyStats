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
    let solarService: SolarForecastProviding
    @State private var alert: AlertContent?

    var body: some View {
        Section {
            Group {
                Toggle(isOn: $viewModel.showColouredLines) {
                    Text("Show coloured flow lines")
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

            Group {
                Toggle(isOn: $viewModel.showLastUpdateTimestamp) {
                    Text("Show timestamp of last update")
                }

                Toggle(isOn: $viewModel.showGraphValueDescriptions) {
                    Text("Show graph value descriptions")
                }

                Toggle(isOn: $viewModel.separateParameterGraphsByUnit) {
                    Text("Separate parameter graphs by unit")
                }

                Toggle(isOn: $viewModel.showBatteryPercentageRemaining) {
                    Text("Show battery percentage remaining")
                }
            }

            Toggle(isOn: $viewModel.showTotalYieldOnPowerFlow) {
                HStack {
                    Text("settings.yield.title")
                    InfoButtonView(message: "settings.yield.description")
                }
            }

            SolarStringsSettingsView(viewModel: viewModel)

            NavigationLink {
                SolarBandingSettingsView(configManager: configManager)
            } label: {
                Text("Sun display variation thresholds")
            }

        } header: {
            Text("Display")
        } footer: {
            Text("Some settings will only take effect on the next data refresh")
        }

        NavigationLink {
            DataSettingsView(viewModel: viewModel)
        } label: {
            Text("Data")
        }

        NavigationLink {
            SelfSufficiencySettingsView(configManager: configManager)
        } label: {
            Text("Self sufficiency estimates")
        }

        NavigationLink {
            FinancialsSettingsView(configManager: configManager)
        } label: {
            Text("Earnings")
                .accessibilityIdentifier("financials")
        }

        NavigationLink {
            SolcastSettingsView(configManager: configManager, solarService: solarService)
        } label: {
            Text("Solcast solar prediction")
        }
    }
}

#if DEBUG
struct DisplaySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            DisplaySettingsView(
                viewModel: SettingsTabViewModel(
                    userManager: .preview(),
                    config: ConfigManager.preview(),
                    networking: NetworkService.preview()),
                configManager: ConfigManager.preview(),
                solarService: { DemoSolcast() })
        }
    }
}
#endif
