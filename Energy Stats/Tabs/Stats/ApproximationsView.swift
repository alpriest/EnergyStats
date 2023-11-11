//
//  ApproximationsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/08/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ApproximationsView: View {
    let viewModel: ApproximationsViewModel
    let appTheme: AppTheme
    @Environment(\.colorScheme) var colorScheme
    @State private var showCalculations = false
    let decimalPlaceOverride: Int?

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color("highlight_box"), lineWidth: 1)
                .background(Color("highlight_box").opacity(0.1))
                .padding(1)

            HStack {
                Text("Approximations")
                    .padding(2)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color("highlight_box"))
                    )
                    .font(.caption2.weight(.bold))
                    .offset(x: 8, y: -8)
                    .foregroundColor(Color.white.opacity(colorScheme == .dark ? 0.8 : 1.0))

                Spacer()

                Image(systemName: showCalculations ? "eye" : "eye.slash")
                    .padding(2)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color("highlight_box"))
                    )
                    .multilineTextAlignment(.trailing)
                    .font(.caption2.weight(.bold))
                    .offset(x: -8, y: -8)
                    .foregroundColor(Color.white.opacity(colorScheme == .dark ? 0.8 : 1.0))
                    .onTapGesture {
                        withAnimation {
                            showCalculations.toggle()
                        }
                    }
            }

            ZStack {
                VStack {
                    if appTheme.selfSufficiencyEstimateMode != .off {
                        SelfSufficiencyEstimateView(viewModel, mode: appTheme.selfSufficiencyEstimateMode, showCalculations: showCalculations, decimalPlaces: appTheme.decimalPlaces)
                    }

                    if let home = viewModel.homeUsage {
                        HStack {
                            Text("Home usage")
                                .accessibilityElement(children: .ignore)
                            Spacer()
                            EnergyText(amount: home, appTheme: appTheme, type: .selfSufficiency, decimalPlaceOverride: decimalPlaceOverride)
                        }
                    }

                    if let totals = viewModel.totalsViewModel {
                        VStack(spacing: 2) {
                            HStack {
                                Text("Solar generated")
                                    .accessibilityElement(children: .ignore)
                                Spacer()
                                EnergyText(amount: totals.solar, appTheme: appTheme, type: .totalSolarGenerated, decimalPlaceOverride: decimalPlaceOverride)
                            }

                            if showCalculations {
                                CalculationBreakdownView(breakdown: totals.solarBreakdown, decimalPlaces: appTheme.decimalPlaces)
                            }
                        }
                    }

                    if let financialModel = viewModel.financialModel, case .energyStats = appTheme.financialModel {
                        VStack(spacing: 2) {
                            HStack {
                                Text("Export income")
                                Spacer()
                                Text(financialModel.exportIncome.formattedAmount())
                            }
                            if showCalculations {
                                CalculationBreakdownView(breakdown: financialModel.exportBreakdown, decimalPlaces: appTheme.decimalPlaces)
                            }
                        }

                        VStack(spacing: 2) {
                            HStack {
                                Text("Grid import avoided")
                                Spacer()
                                Text(financialModel.solarSaving.formattedAmount())
                            }
                            if showCalculations {
                                CalculationBreakdownView(breakdown: financialModel.solarSavingBreakdown, decimalPlaces: appTheme.decimalPlaces)
                            }
                        }

                        HStack {
                            Text("Total benefit")
                            Spacer()
                            Text(financialModel.total.formattedAmount())
                        }
                    }

                    if let earnings = viewModel.earnings, case .foxESS = appTheme.financialModel {
                        VStack(spacing: 2) {
                            HStack {
                                Text("Accumulated income")
                                Spacer()
                                Text(FinanceAmount(title: .total, amount: earnings.cumulate.earnings, currencySymbol: earnings.currencySymbol).formattedAmount())
                            }
                        }
                    }
                }
                .padding()
                .monospacedDigit()
            }
        }
        .padding(.top)
    }
}

struct CalculationBreakdownView: View {
    let breakdown: CalculationBreakdown
    let decimalPlaces: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color("highlight_box"), lineWidth: 1)
                .background(Color("highlight_box").opacity(0.1))

            VStack(alignment: .leading, spacing: 8) {
                Text(breakdown.formula)
                    .italic()

                Text(breakdown.calculation(decimalPlaces))
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            .padding(5)
        }
        .fixedSize(horizontal: false, vertical: true)
        .font(.caption2)
        .padding(.bottom)
    }
}

#if DEBUG
#Preview {
    ApproximationsView(viewModel: .any(),
                       appTheme: .mock(selfSufficiencyEstimateMode: .net),
                       decimalPlaceOverride: nil)
}

#Preview {
    CalculationBreakdownView(
        breakdown: CalculationBreakdown(
            formula: "max(0, batteryCharge - batteryDischarge - gridImport + home + gridExport)",
            calculation: { _ in "max(0, 7.6 - 7.4 - 4.9 + 9.4 + 3.1)" }
        ),
        decimalPlaces: 2
    )
}
#endif
