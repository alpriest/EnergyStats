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
                            Text("ct2").tag(EarningsModel.ct2)
                        }.pickerStyle(.segmented)
                    }

                } footer: {
                    switch viewModel.earningsModel {
                    case .generated:
                        Text("Enter the unit price you are paid per kWh for generating electricity")
                    case .exported:
                        Text("Enter the unit price you are paid per kWh for exporting electricity")
                    case .ct2:
                        Text("Enter the unit price you are paid per kWh for exporting electricity via another inverter tracked via CT2. This will only show earnings data on the power flow page because Fox do not store historical CT2 statistics.")
                    }
                }

                Section {
                    makeTextField(
                        title: "Grid Import Unit price",
                        currencySymbol: viewModel.currencySymbol,
                        text: $viewModel.energyStatsGridImportUnitPrice
                    )
                } footer: {
                    Text("Enter the price you pay per kWh for importing electricity")
                }

                Section {} footer: {
                    energyStatsFooter()
                }
            }
        }
        .navigationTitle(.financialModel)
    }

    @ViewBuilder
    func energyStatsFooter() -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("exported_income_short_title").bold()

                switch viewModel.earningsModel {
                case .generated:
                    Text("Approximate income received from generating electricity.")
                case .exported:
                    Text("Approximate income received from exporting energy to the grid.")
                case .ct2:
                    Text("Approximate income received from exporting energy to the grid via another inverter tracked by CT2.")
                }

                VStack(alignment: .center) {
                    switch viewModel.earningsModel {
                    case .generated:
                        Text("SolarGeneration kWh * Unit Price").italic()
                    case .exported:
                        Text("Feed-In kWh * FeedInUnitPrice").italic()
                    case .ct2:
                        Text("CT2 kWh * Unit Price").italic()
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
