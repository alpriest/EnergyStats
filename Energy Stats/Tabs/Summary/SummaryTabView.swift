//
//  SummaryTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/11/2023.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct SummaryTabView: View {
    @StateObject var viewModel: SummaryTabViewModel
    @State private var appSettings: AppSettings
    private var appSettingsPublisher: LatestAppSettingsPublisher
    private let configManager: ConfigManaging
    @StateObject private var solarForecastViewModel: SolarForecastViewModel

    init(configManager: ConfigManaging, networking: Networking, appSettingsPublisher: LatestAppSettingsPublisher, solarForecastProvider: @escaping SolarForecastProviding) {
        self.configManager = configManager
        _viewModel = .init(wrappedValue: SummaryTabViewModel(configManager: configManager, networking: networking))
        _solarForecastViewModel = .init(wrappedValue: SolarForecastViewModel(configManager: configManager, appSettingsPublisher: appSettingsPublisher, solarForecastProvider: solarForecastProvider))
        _appSettings = State(initialValue: appSettingsPublisher.value)
        self.appSettingsPublisher = appSettingsPublisher
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    if viewModel.isLoading {
                        Group {
                            if #available(iOS 17.0, *) {
                                Image(systemName: "chart.bar.xaxis.ascending")
                                    .font(.system(size: 72))
                                    .symbolEffect(.variableColor.iterative, options: .repeating)
                            } else {
                                Image(systemName: "chart.bar.xaxis.ascending")
                            }
                        }
                    } else {
                        if let approximationsViewModel = viewModel.approximationsViewModel {
                            energySummaryRow(title: "home_usage", amount: approximationsViewModel.homeUsage)
                            energySummaryRow(title: "solar_generated", amount: approximationsViewModel.totalsViewModel?.solar)

                            Spacer(minLength: 22)

                            if let model = approximationsViewModel.financialModel {
                                moneySummaryRow(title: "export_income", amount: model.exportIncome.amount)
                                moneySummaryRow(title: "grid_import_avoided", amount: model.solarSaving.amount)
                                moneySummaryRow(title: "total_benefit", amount: model.total.amount)
                            }

                            Text("Includes data from \(viewModel.oldestDataDate) to Present. Figures are approximate and assume the buy/sell energy prices remained constant throughout the period of ownership.")
                                .font(.caption2)
                                .padding(.vertical)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Could not load approximations")
                        }

                        if #available(iOS 16.0, *) {
                            Divider()
                            SolarForecastView(appSettings: appSettings, viewModel: solarForecastViewModel)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Summary")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.load()
        }
        .onReceive(appSettingsPublisher) {
            self.appSettings = $0
        }
    }

    @ViewBuilder
    private func energySummaryRow(title: LocalizedStringKey, amount: Double?) -> some View {
        summaryRow(title: title, amount: amount) {
            EnergyText(amount: $0, appSettings: appSettings, type: .default, decimalPlaceOverride: 0)
                .font(.title2)
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private func moneySummaryRow(title: LocalizedStringKey, amount: Double?) -> some View {
        summaryRow(title: title, amount: amount) {
            Text(FinanceAmount(title: .total, amount: $0).formattedAmount(viewModel.currencySymbol))
                .font(.title2)
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private func summaryRow(title: LocalizedStringKey, amount: Double?, text: @escaping (Double) -> some View) -> some View {
        if let amount {
            HStack {
                Text(title)
                    .font(.title2)

                Spacer()

                AnimatedNumber(target: amount) {
                    text($0)
                }
            }
        }
    }
}

#Preview {
    SummaryTabView(configManager: ConfigManager.preview(),
                   networking: DemoNetworking(),
                   appSettingsPublisher: CurrentValueSubject(.mock()),
                   solarForecastProvider: { DemoSolcast() })
}
