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
    @State private var presentSheet = false

    init(configManager: ConfigManaging, networking: Networking, appSettingsPublisher: LatestAppSettingsPublisher, solarForecastProvider: @escaping SolarForecastProviding) {
        self.configManager = configManager
        _viewModel = .init(wrappedValue: SummaryTabViewModel(configManager: configManager, networking: networking))
        _solarForecastViewModel = .init(wrappedValue: SolarForecastViewModel(configManager: configManager, appSettingsPublisher: appSettingsPublisher, solarForecastProvider: solarForecastProvider))
        _appSettings = State(initialValue: appSettingsPublisher.value)
        self.appSettingsPublisher = appSettingsPublisher
    }

    var body: some View {
        NavigationStack {
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

                            if viewModel.hasPV {
                                energySummaryRow(title: "solar_generated", amount: approximationsViewModel.totalsViewModel?.solar)
                            } else {
                                Text("Your inverter doesn't store PV generation data so we can't show historic solar data.")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer(minLength: 22)

                            if let model = approximationsViewModel.financialModel {
                                moneySummaryRow(title: "export_income", amount: model.exportIncome.amount)
                                moneySummaryRow(title: "grid_import_avoided", amount: model.solarSaving.amount)
                                moneySummaryRow(title: "total_benefit", amount: model.total.amount)
                            }

                            Text("Includes data from \(viewModel.oldestDataDate) to \(viewModel.latestDataDate). Figures are approximate and assume the buy/sell energy prices remained constant throughout the period of ownership. FoxESS only makes data available for the last 12 months.")
                                .font(.caption2)
                                .padding(.vertical)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Could not load approximations")
                        }

                        Divider()
                        SolarForecastView(appSettings: appSettings, viewModel: solarForecastViewModel)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Summary: Past Year")
            .analyticsScreen(.summary)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentSheet.toggle() },
                           label: { Text("Edit") })
                }
            }
            .sheet(isPresented: $presentSheet) {
                SummaryDateRangeView(initial: viewModel.summaryDateRange, onApply: { dateRange in
                    viewModel.setDateRange(dateRange: dateRange)
                })
                .presentationDetents([.medium])
            }
        }
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
            Text(FinanceAmount(title: .total, accessibilityKey: .totalIncomeToday, amount: $0).formattedAmount(viewModel.currencySymbol))
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
                   networking: NetworkService.preview(),
                   appSettingsPublisher: CurrentValueSubject(.mock()),
                   solarForecastProvider: { DemoSolcast() })
    .environment(\.locale, .init(identifier: "de"))
}
