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

    @Published var showEarnings: Bool {
        didSet {
            configManager.showEarnings = showEarnings
        }
    }

    @Published var showSavings: Bool {
        didSet {
            // TODO
        }
    }

    @Published var showCosts: Bool {
        didSet {
            // TODO
        }
    }

    private(set) var configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        selfSufficiencyEstimateMode = configManager.selfSufficiencyEstimateMode
        showEarnings = configManager.showEarnings
        showSavings = true // TODO
        showCosts = true // TODO
    }
}

enum FinancialModel {
    case energyStats
    case foxESS
}

struct ApproximationsSettingsView: View {
    @StateObject private var viewModel: ApproximationsSettingsViewModel
    @State private var financialModel = FinancialModel.energyStats
    @State private var foxFeedInUnitPrice = "0.30"
    @State private var energyStatsFeedInUnitPrice = ""

    init(configManager: ConfigManaging) {
        _viewModel = .init(wrappedValue: ApproximationsSettingsViewModel(configManager: configManager))
    }

    var body: some View {
        Form {
            SelfSufficiencySettingsView(mode: $viewModel.selfSufficiencyEstimateMode)

            Section {
                Picker("Financial Model", selection: $financialModel) {
                    Text("Energy Stats").tag(FinancialModel.energyStats)
                    Text("FoxESS").tag(FinancialModel.foxESS)
                }.pickerStyle(.segmented)
            } header: {
                Text("Financials")
            }

            switch financialModel {
            case .energyStats:
                Section {
                    Toggle(isOn: $viewModel.showEarnings) {
                        Text("Show estimated earnings")
                    }

                    makeTextField(title: "Feed In Unit price", currencyCode: "£", text: $energyStatsFeedInUnitPrice)
                } header: {
                    Text("Energy Stats Model")
                } footer: {
                    Text("Shows earnings today, this month, this year, and all-time based on a calculation of feed-in kWh * unit price.")
                }

                Section {
                    Toggle(isOn: $viewModel.showSavings) {
                        Text("Show estimated savings")
                    }

                    makeTextField(title: "Grid Import Unit price", currencyCode: "£", text: $energyStatsFeedInUnitPrice)
                } footer: {
                    Text("Shows savings today, this month, this year, and all-time based on a calculation of solar generated kWh * unit price.")
                }

                Section {
                    Toggle(isOn: $viewModel.showCosts) {
                        Text("Show estimated costs")
                    }
                } footer: {
                    Text("Shows costs today, this month, this year, and all-time based on a calculation of grid import kWh * unit price.")
                }
            case .foxESS:
                Section {
                    Toggle(isOn: $viewModel.showEarnings) {
                        Text("Show estimated earnings")
                    }

                    makeTextField(title: "Unit price", currencyCode: "£", text: $foxFeedInUnitPrice)
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
