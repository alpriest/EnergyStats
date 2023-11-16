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
    @State private var appTheme: AppTheme
    private var appThemePublisher: LatestAppTheme
    private let configManager: ConfigManaging
    @StateObject private var solarForecastViewModel: SolarForecastViewModel

    init(configManager: ConfigManaging, networking: Networking, appThemePublisher: LatestAppTheme) {
        self.configManager = configManager
        _viewModel = .init(wrappedValue: SummaryTabViewModel(configManager: configManager, networking: networking))
        _solarForecastViewModel = .init(wrappedValue: SolarForecastViewModel(configManager: configManager, appTheme: appThemePublisher))
        _appTheme = State(initialValue: appThemePublisher.value)
        self.appThemePublisher = appThemePublisher
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
                            energySummaryRow(title: "Home usage", amount: approximationsViewModel.homeUsage)
                            energySummaryRow(title: "Solar generated", amount: approximationsViewModel.totalsViewModel?.solar)

                            Spacer(minLength: 22)

                            if let model = approximationsViewModel.financialModel, case .energyStats = appTheme.financialModel {
                                moneySummaryRow(title: "Export income", amount: model.exportIncome.amount)
                                moneySummaryRow(title: "Grid import avoided", amount: model.solarSaving.amount)
                                moneySummaryRow(title: "Total benefit", amount: model.total.amount)
                            }

                            if let earnings = approximationsViewModel.earnings, case .foxESS = appTheme.financialModel {
                                moneySummaryRow(title: "Total benefit", amount: earnings.cumulate.earnings)
                            }

                            Text("Includes data from \(viewModel.oldestDataDate) to Present. Figures are approximate and assume the buy/sell energy prices remained constant throughout the period of ownership.")
                                .font(.caption2)
                                .padding(.vertical)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Could not load approximations")
                        }

                        if #available (iOS 16.0, *) {
                            Divider()
                            SolarForecastView(appTheme: appTheme, viewModel: solarForecastViewModel)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Summary")
        }
        .onAppear {
            viewModel.load()
        }
        .onReceive(appThemePublisher) {
            self.appTheme = $0
        }
    }

    @ViewBuilder
    private func energySummaryRow(title: String, amount: Double?) -> some View {
        summaryRow(title: title, amount: amount) {
            EnergyText(amount: $0, appTheme: appTheme, type: .default, decimalPlaceOverride: 0)
                .font(.title2)
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private func moneySummaryRow(title: String, amount: Double?) -> some View {
        summaryRow(title: title, amount: amount) {
            Text(FinanceAmount(title: .total, amount: $0, currencySymbol: viewModel.currencySymbol).formattedAmount())
                .font(.title2)
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private func summaryRow(title: String, amount: Double?, text: @escaping (Double) -> some View) -> some View {
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
    SummaryTabView(configManager: PreviewConfigManager(),
                   networking: DemoNetworking(),
                   appThemePublisher: CurrentValueSubject(.mock()))
}
