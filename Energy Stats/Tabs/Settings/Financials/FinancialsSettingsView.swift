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
                    Text("Show estimated earnings")
                }.accessibilityIdentifier("toggle_financial_summary")

            } footer: {
                Text("energy_stats_earnings_calculation_description")
            }

            if viewModel.showFinancialSummary {
                Section {
                    Toggle(isOn: $viewModel.showFinancialSummaryOnFlowPage) {
                        Text("Show on power flow page")
                    }

                    makeCurrencySymbolField()
                }

                Section {
                    makeTextField(
                        title: "Unit price",
                        currencySymbol: viewModel.currencySymbol,
                        text: $viewModel.energyStatsFeedInUnitPrice
                    )

                    HStack {
                        Text("I am paid for")
                        Picker("Payment model", selection: $viewModel.earningsModel) {
                            Text("exporting").tag(EarningsModel.exported)
                            Text("generating").tag(EarningsModel.generated)
                        }.pickerStyle(.segmented)
                    }

                } footer: {
                    switch viewModel.earningsModel {
                    case .generated:
                        Text("Enter the unit price you are paid per kWh for generating electricity")
                    case .exported:
                        Text("Enter the unit price you are paid per kWh for exporting electricity")
                    }
                }

                Section {
                    makeTextField(
                        title: "Grid Import Unit price",
                        currencySymbol: viewModel.currencySymbol,
                        text: $viewModel.energyStatsGridImportUnitPrice
                    )
                } footer: {
                    Text("Enter the price you pay for kWh for importing electricity")
                }

                Section {} footer: {
                    energyStatsFooter()
                }
            }
        }
        .navigationTitle("Financial Model")
    }

    @ViewBuilder
    func energyStatsFooter() -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                switch viewModel.earningsModel {
                case .generated:
                    Text("generated_income_short_title").bold()
                    Text("Approximate income received from generating electricity.")
                case .exported:
                    Text("exported_income_short_title").bold()
                    Text("Approximate income received from exporting energy to the grid.")
                }

                VStack(alignment: .center) {
                    switch viewModel.earningsModel {
                    case .generated:
                        Text("Feed-In kWh * FeedInUnitPrice").italic()
                    case .exported:
                        Text("SolarGeneration kWh * Unit Price").italic()
                    }
                }.frame(maxWidth: .infinity)
            }
            .padding(.bottom, 16)

            VStack(alignment: .leading) {
                Text("grid_import_avoided_short_title").bold()

                Text("grid_import_avoided_long_description")

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

    private func makeTextField(
        title: LocalizedStringKey,
        currencySymbol: String,
        text: Binding<String>
    ) -> some View {
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

    private func makeCurrencySymbolField() -> some View {
        HStack {
            Text("Currency symbol")
            Spacer()
            TextField("", text: $viewModel.currencySymbol)
        }
        .multilineTextAlignment(.trailing)
    }
}

#Preview {
    FinancialsSettingsView(configManager: ConfigManager.preview())
}
