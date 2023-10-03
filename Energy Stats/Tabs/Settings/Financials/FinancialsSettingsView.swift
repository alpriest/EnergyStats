//
//  FinancialsSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/10/2023.
//

import SwiftUI
import Energy_Stats_Core

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
                    Text("energy_stats_earnings_calculation_description")
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

#Preview {
    FinancialsSettingsView(configManager: PreviewConfigManager())
}
