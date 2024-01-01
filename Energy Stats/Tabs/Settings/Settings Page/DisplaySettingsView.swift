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
                    Text("Show last update timestamp")
                }

                Toggle(isOn: $viewModel.showGraphValueDescriptions) {
                    Text("Show graph value descriptions")
                }
            }
        } header: {
            Text("Display")
        }

        Section {
            HStack {
                Text("settings.yield.title").padding(.trailing)
                Spacer()
                Picker("settings.yield.title", selection: $viewModel.totalSolarYieldModel) {
                    Text("Off").tag(TotalSolarYieldModel.off)
                    Text("PV Only").tag(TotalSolarYieldModel.energyStats)
                    Text("FoxESS").tag(TotalSolarYieldModel.foxESS)
                }.pickerStyle(.segmented)
            }
        } footer: {
            switch viewModel.totalSolarYieldModel {
            case TotalSolarYieldModel.off:
                EmptyView()
            case TotalSolarYieldModel.energyStats:
                Text("Calculated as a Riemann sum approximation integration of pvPower. This will be reasonably accurate but only for today.")
            case TotalSolarYieldModel.foxESS:
                Text("Uses the FoxESS supplied value which contains battery output and solar output.")
            }
        }
        Section {
            HStack {
                Text("Units").padding(.trailing)
                Spacer()
                Picker("Units", selection: $viewModel.displayUnit) {
                    Text("Watts").tag(DisplayUnit.watt)
                    Text("Kilowatts").tag(DisplayUnit.kilowatt)
                    Text("Adaptive").tag(DisplayUnit.adaptive)
                }.pickerStyle(.segmented)
            }
        } footer: {
            switch viewModel.displayUnit {
            case .kilowatt:
                Text(String(key: .displayUnitKilowattsDescription, arguments: [Double(3.456).kW(viewModel.decimalPlaces), Double(0.123).kW(3)]))
            case .watt:
                Text(String(key: .displayUnitWattsDescription, arguments: [Double(3.456).w(), Double(0.123).w()]))
            case .adaptive:
                Text(String(key: .displayUnitAdaptiveDescription, arguments: [Double(3.456).kW(viewModel.decimalPlaces), Double(0.123).w()]))
            }
        }

        Section {
            HStack {
                Text("Ceiling").padding(.trailing)
                Spacer()
                Picker("Ceiling", selection: $viewModel.dataCeiling) {
                    Text("None").tag(DataCeiling.none)
                    Text("Mild").tag(DataCeiling.mild)
                    Text("Enhanced").tag(DataCeiling.enhanced)
                }.pickerStyle(.segmented)
            }
        } footer: {
            switch viewModel.dataCeiling {
            case .none:
                Text(String(key: .dataCeilingNone))
            case .mild:
                Text(String(key: .dataCeilingMild, arguments: [Double(201539769), Double(3461.8)]))
            case .enhanced:
                Text(String(key: .dataCeilingEnhanced, arguments: [Double(458997), Double(245)]))
            }
        }

        NavigationLink {
            SelfSufficiencySettingsView(configManager: configManager)
        } label: {
            Text("Self Sufficiency Estimates")
        }

        NavigationLink {
            FinancialsSettingsView(configManager: configManager)
        } label: {
            Text("Financial Model")
                .accessibilityIdentifier("financials")
        }

        NavigationLink {
            SolarBandingSettingsView(configManager: configManager)
        } label: {
            Text("Sun display variation thresholds")
        }

        NavigationLink {
            SolcastSettingsView(configManager: configManager, solarService: solarService)
        } label: {
            Text("Solcast Solar Prediction")
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
                    config: PreviewConfigManager(),
                    networking: DemoNetworking()),
                configManager: PreviewConfigManager(),
                solarService: { DemoSolcast() })
        }
    }
}
#endif
