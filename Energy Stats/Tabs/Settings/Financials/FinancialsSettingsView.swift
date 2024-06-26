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

                if viewModel.showFinancialSummary {
                    Toggle(isOn: $viewModel.showFinancialSummaryOnFlowPage) {
                        Text("Show on power flow page")
                    }

                    makeCurrencySymbolField()
                    makeTextField(title: "Feed In Unit price", currencySymbol: viewModel.currencySymbol, text: $viewModel.energyStatsFeedInUnitPrice)
                    makeTextField(title: "Grid Import Unit price", currencySymbol: viewModel.currencySymbol, text: $viewModel.energyStatsGridImportUnitPrice)
                }
            } footer: {
                if viewModel.showFinancialSummary {
                    energyStatsFooter()
                }
            }
        }
        .navigationTitle("Financial Model")
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

    private func makeTextField(title: LocalizedStringKey, currencySymbol: String, text: Binding<String>) -> some View {
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
