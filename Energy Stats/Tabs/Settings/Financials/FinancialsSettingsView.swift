//
//  FinancialsSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/10/2023.
//

import Energy_Stats_Core
import SwiftUI

struct FinancialsSettingsView: View {
    @StateObject private var viewModel: FinancialsSettingsViewModel

    init(configManager: ConfigManaging) {
        _viewModel = .init(wrappedValue: FinancialsSettingsViewModel(configManager: configManager))
    }

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $viewModel.showFinancialSummary) {
                    Text("Show financial summary")
                }.accessibilityIdentifier("toggle_financial_summary")

                if viewModel.showFinancialSummary {
                    Toggle(isOn: $viewModel.showFinancialSummaryOnFlowPage) {
                        Text("Show on flow page")
                    }

                    Picker("Financial Model", selection: $viewModel.financialModel) {
                        Text("Energy Stats")
                            .tag(FinancialModel.energyStats)
                        Text("FoxESS").tag(FinancialModel.foxESS)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("show_energy_stats_model")

                    switch viewModel.financialModel {
                    case .energyStats:
                        makeTextField(title: "Feed In Unit price", currencySymbol: viewModel.currencySymbol, text: $viewModel.energyStatsFeedInUnitPrice)
                        makeTextField(title: "Grid Import Unit price", currencySymbol: viewModel.currencySymbol, text: $viewModel.energyStatsGridImportUnitPrice)
                    case .foxESS:
                        EmptyView()
                    }
                }
            } footer: {
                if viewModel.showFinancialSummary {
                    switch viewModel.financialModel {
                    case .energyStats:
                        energyStatsFooter()
                    case .foxESS:
                        VStack(alignment: .leading, spacing: 8) {
                            Text("This unit price is managed on the FoxESS Cloud.")
                            Text("foxess_earnings_calculation_description")
                        }
                    }
                }
            }
        }
        .navigationTitle("Financial Model")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func energyStatsFooter() -> some View {
        VStack(alignment: .leading) {
            Text("energy_stats_earnings_calculation_description")
                .padding(.bottom, 24)

            VStack(alignment: .leading) {
                Text("exported_income_short_title").bold()

                Text("Approximate income received from exporting energy to the grid.")

                VStack(alignment: .center) {
                    Text("Feed-In kWh * FeedInUnitPrice").italic()
                }.frame(maxWidth: .infinity)
            }
            .padding(.bottom, 16)

            VStack(alignment: .leading) {
                Text("grid_import_avoided_short_title").bold()

                Text("Approximate expenditure avoided by generating your own solar power.")

                VStack(alignment: .center) {
                    Text("(SolarGeneration kWh - Feed-In kWh) * ImportUnitPrice").italic()
                }.frame(maxWidth: .infinity)
            }
            .padding(.bottom, 16)

            VStack(alignment: .leading) {
                Text("total").bold()

                Text("Approximate total benefit of having your solar/battery installation.")

                VStack(alignment: .center) {
                    (Text("exported_income_short_title") + Text(" + ") + Text("grid_import_avoided_short_title")).italic()
                }.frame(maxWidth: .infinity)
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
    }

    func makeTextField(title: LocalizedStringKey, currencySymbol: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
                .multilineTextAlignment(.leading)
            Spacer()
            Text(currencySymbol)
            TextField(0.roundedToString(decimalPlaces: 2, currencySymbol: currencySymbol), text: text)
                .frame(width: 60)
                .monospacedDigit()
        }
        .multilineTextAlignment(.trailing)
    }
}

#Preview {
    FinancialsSettingsView(configManager: PreviewConfigManager())
}
