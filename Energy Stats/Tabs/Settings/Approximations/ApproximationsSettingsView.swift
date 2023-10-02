//
//  ApproximationsSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/08/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ApproximationsSettingsView: View {
    @StateObject private var viewModel: ApproximationsSettingsViewModel

    init(configManager: ConfigManaging) {
        _viewModel = .init(wrappedValue: ApproximationsSettingsViewModel(configManager: configManager))
    }

    var body: some View {
        Form {
            SelfSufficiencySettingsView(mode: $viewModel.selfSufficiencyEstimateMode)

            Section {
                Toggle(isOn: $viewModel.showFinancialSummary) {
                    Text("Show financial summary")
                }

                if viewModel.showFinancialSummary {
                    Picker("Financial Model", selection: $viewModel.financialModel) {
                        Text("Energy Stats").tag(FinancialModel.energyStats)
                        Text("FoxESS").tag(FinancialModel.foxESS)
                    }
                    .pickerStyle(.segmented)
                }
            } header: {
                Text("Financials")
            } footer: {
                if viewModel.showFinancialSummary {
                    switch viewModel.financialModel {
                    case .energyStats:
                        Text("Shows net financial estimate for today only on the flow page, and full breakdown the selected time period on the stats page.")
                    case .foxESS:
                        Text("foxess_earnings_calculation_description")
                    }
                }
            }

            if viewModel.showFinancialSummary {
                switch viewModel.financialModel {
                case .energyStats:
                    energyStats()
                case .foxESS:
                    foxESS()
                }
            }
        }
        .navigationTitle("Approximations")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func energyStats() -> some View {
        Section {
            makeTextField(title: "Feed In Unit price", currencyCode: "£", text: $viewModel.energyStatsFeedInUnitPrice)
            makeTextField(title: "Grid Import Unit price", currencyCode: "£", text: $viewModel.energyStatsGridImportUnitPrice)
        } footer: {
            VStack(alignment: .leading) {
                Text("Financial summary is a total of:")
                    .padding(.bottom, 16)

                VStack(alignment: .center, spacing: 8) {
                    Text("Feed-In kWh * FeedInUnitPrice")
                    Text("+")
                    Text("(SolarGeneration kWh - Feed-In kWh) * ImportUnitPrice")
                    Text("-")
                    Text("GridImport kWh * ImportUnitPrice")
                }.frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    func foxESS() -> some View {
        Section {
            makeTextField(title: "Feed In Unit price", currencyCode: "£", text: $viewModel.foxFeedInUnitPrice)
        } footer: {
            Text("This unit price is stored on the FoxESS Cloud.")
        }
    }

    func makeTextField(title: LocalizedStringKey, currencyCode: LocalizedStringKey, text: Binding<String>) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(currencyCode)
            TextField(0.roundedToString(decimalPlaces: 2, currencySymbol: nil), text: text)
                .frame(width: 50)
        }
        .multilineTextAlignment(.trailing)
    }
}

#if DEBUG
struct ApproximationsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ApproximationsSettingsView(configManager: PreviewConfigManager())
        }
    }
}
#endif
