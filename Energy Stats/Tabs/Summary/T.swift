//
//  SummaryLoadedView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 18/05/2026.
//

import Energy_Stats_Core
import SwiftUI

struct SummaryLoadedView: View {
    let viewData: SummaryViewData
    let appSettings: AppSettings
    let onToggleBestSolar: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            energySummaryRow(title: "home_usage", amount: viewData.homeUsage)
                .card()

            energySummaryRow(title: "solar_generated", amount: viewData.solar)
                .card()

            if viewData.hasPV {
                bestSolarPeriod(viewData.bestSolar)
            } else {
                Text("Your inverter doesn't store PV generation data so we can't show historic solar data.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if let model = viewData.financialData {
                financialSummary(model: model)
            }

            Text("Includes data from \(viewData.oldestDataDate) to \(viewData.latestDataDate). Figures are approximate and assume the buy/sell energy prices remained constant throughout the period of ownership.")
                .font(.caption2)
                .padding(.vertical)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func bestSolarPeriod(_ model: SummaryViewData.BestSolarData?) -> some View {
        if let model {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("Best solar")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button {
                        onToggleBestSolar()
                    } label: {
                        Text(model.period.title)
                            .font(.caption)
                    }
                }

                HStack {
                    Text(model.description)
                        .font(.title3)

                    Spacer()

                    NumberRollerView(text: model.amount.kWh(0))
                        .id(model.amount)
                        .font(.title2)
                }
            }
            .card()
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func financialSummary(model: SummaryViewData.FinancialData) -> some View {
        VStack {
            moneySummaryRow(title: "export_income", amount: model.exportIncome)
            moneySummaryRow(title: "grid_import_avoided", amount: model.gridImportAvoided)
            moneySummaryRow(title: "total_benefit", amount: model.totalBenefit)

            if let payback = model.payback {
                summaryRow(
                    title: "Time to payback",
                    amount: paybackYears(payback.paybackMonths),
                    infoButtonText: payback.infoText
                ) { amount in
                    amount.roundedToString(decimalPlaces: 1) + " years"
                }
            }
        }
        .card()
    }
    
    private func paybackYears(_ months: Int) -> Double {
        (Double(months) / 12.0).rounded(decimalPlaces: 1)
    }

    @ViewBuilder
    private func energySummaryRow(title: LocalizedStringKey, amount: Double?) -> some View {
        summaryRow(title: title, amount: amount) {
            $0.withUnit(appSettings, decimalPlaceOverride: 0)
        }
    }

    @ViewBuilder
    private func moneySummaryRow(title: LocalizedStringKey, amount: Double?) -> some View {
        summaryRow(title: title, amount: amount) {
            FinanceAmount(title: .total, accessibilityKey: .totalIncomeToday, amount: $0).formattedAmount(viewData.currencySymbol)
        }
    }

    @ViewBuilder
    private func summaryRow(
        title: LocalizedStringKey,
        amount: Double?,
        infoButtonText: LocalizedStringKey? = nil,
        text: @escaping (Double) -> String
    ) -> some View {
        if let amount {
            HStack(alignment: .top) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(.title2)

                    if let infoButtonText {
                        InfoButtonView(message: infoButtonText)
                    }
                }

                Spacer()

//                Text(text(amount))
                NumberRollerView(text: text(amount))
            }
        }
    }
}

extension View {
    func card() -> some View {
        modifier(Card())
    }
}

struct Card: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VStack {
        SummaryLoadedView(
            viewData: SummaryViewData(
                solar: 15122,
                homeUsage: 22023,
                financialData: SummaryViewData.FinancialData(
                    exportIncome: 385.73,
                    gridImportAvoided: 1111.05,
                    totalBenefit: 1496.78,
                    payback: SummaryViewData.FinancialData.PaybackData(
                        paybackMonths: 33,
                        purchasePrice: "£11,000",
                        oldestDataDate: Date.now.startOfMonth()
                    )
                ),
                bestSolar: SummaryViewData.BestSolarData(description: "March, 2025", amount: 543.23, period: .month),
                hasPV: true,
                oldestDataDate: "Aug 2022",
                latestDataDate: "present",
                currencySymbol: "£"
            ),
            appSettings: .mock(),
            onToggleBestSolar: {
            }
        )

        Spacer()
    }
}
