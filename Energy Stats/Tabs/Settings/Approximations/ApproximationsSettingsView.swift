//
//  ApproximationsSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/08/2023.
//

import Energy_Stats_Core
import SwiftUI

class ApproximationsSettingsViewModel: ObservableObject {
    @Published var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode {
        didSet {
            configManager.selfSufficiencyEstimateMode = selfSufficiencyEstimateMode
        }
    }

    @Published var showFinancialEarnings: Bool {
        didSet {
            configManager.showFinancialEarnings = showFinancialEarnings
        }
    }

    @Published var showFinancialSavings: Bool {
        didSet {
            configManager.showFinancialSavings = showFinancialSavings
        }
    }

    @Published var showFinancialCosts: Bool {
        didSet {
            configManager.showFinancialCosts = showFinancialCosts
        }
    }

    @Published var financialModel: FinancialModel {
        didSet {
            configManager.financialModel = financialModel
        }
    }

    @Published var foxFeedInUnitPrice = "0.30" // TODO Read from Fox
    @Published var energyStatsFeedInUnitPrice = "0.12" // TODO Write to config
    @Published var energyStatsGridImportUnitPrice = "0.39" // TODO Write to config

    private(set) var configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        selfSufficiencyEstimateMode = configManager.selfSufficiencyEstimateMode
        showFinancialEarnings = configManager.showFinancialEarnings
        showFinancialSavings = configManager.showFinancialSavings
        showFinancialCosts = configManager.showFinancialCosts
        financialModel = configManager.financialModel
    }
}

struct ApproximationsSettingsView: View {
    @StateObject private var viewModel: ApproximationsSettingsViewModel

    init(configManager: ConfigManaging) {
        _viewModel = .init(wrappedValue: ApproximationsSettingsViewModel(configManager: configManager))
    }

    var body: some View {
        Form {
            SelfSufficiencySettingsView(mode: $viewModel.selfSufficiencyEstimateMode)

            Section {
                Picker("Financial Model", selection: $viewModel.financialModel) {
                    Text("Energy Stats").tag(FinancialModel.energyStats)
                    Text("FoxESS").tag(FinancialModel.foxESS)
                }.pickerStyle(.segmented)
            } header: {
                Text("Financials")
            }

            switch viewModel.financialModel {
            case .energyStats:
                Section {
                    Toggle(isOn: $viewModel.showFinancialEarnings) {
                        Text("Show estimated earnings")
                    }

                    makeTextField(title: "Feed In Unit price", currencyCode: "£", text: $viewModel.energyStatsFeedInUnitPrice)
                } header: {
                    Text("Energy Stats Model")
                } footer: {
                    Text("Shows earnings based on how much you have exported.\n\nFeed-In kWh * FeedInUnitPrice")
                }

                Section {
                    Toggle(isOn: $viewModel.showFinancialSavings) {
                        Text("Show estimated savings")
                    }

                    makeTextField(title: "Grid Import Unit price", currencyCode: "£", text: $viewModel.energyStatsGridImportUnitPrice)
                } footer: {
                    Text("Shows savings based on how much solar you have generated and used that you would have otherwise had to purchase.\n\n(SolarGeneration kWh - Feed-In kWh) * ImportUnitPrice")
                }

                Section {
                    Toggle(isOn: $viewModel.showFinancialCosts) {
                        Text("Show estimated costs")
                    }
                } footer: {
                    Text("Shows costs based on how much you imported.\n\nGridImport kWh * ImportUnitPrice")
                }
            case .foxESS:
                Section {
                    Toggle(isOn: $viewModel.showFinancialEarnings) {
                        Text("Show estimated earnings")
                    }

                    makeTextField(title: "Unit price", currencyCode: "£", text: $viewModel.foxFeedInUnitPrice)
                } header: {
                    Text("FoxESS Model")
                } footer: {
                    Text("foxess_earnings_calculation_description")
                }
            }
        }
        .navigationTitle("Approximations")
        .navigationBarTitleDisplayMode(.inline)
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
