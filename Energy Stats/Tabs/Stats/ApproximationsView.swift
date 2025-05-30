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
    let appSettings: AppSettings
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
                    .accessibilityAddTraits(.isHeader)

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
                    .accessibilityLabel(showCalculations ? "accessibility.hideCalculations" : "accessibility.showCalculations")
            }

            ZStack {
                VStack {
                    if appSettings.selfSufficiencyEstimateMode != .off {
                        SelfSufficiencyEstimateView(viewModel, mode: appSettings.selfSufficiencyEstimateMode, showCalculations: showCalculations, decimalPlaces: appSettings.decimalPlaces)
                    }

                    if let financialModel = viewModel.financialModel {
                        VStack(spacing: 2) {
                            HStack {
                                Text(String(key: financialModel.exportIncome.longTitle))
                                    .accessibilityHidden(true)
                                Spacer()
                                Text(financialModel.exportIncome.formattedAmount(appSettings.currencySymbol))
                                    .accessibilityLabel(financialModel.exportIncome.accessibilityLabel(appSettings.currencySymbol))
                            }
                            if showCalculations {
                                CalculationBreakdownView(breakdown: financialModel.exportBreakdown, decimalPlaces: appSettings.decimalPlaces)
                            }
                        }

                        VStack(spacing: 2) {
                            HStack {
                                Text("grid_import_avoided")
                                    .accessibilityHidden(true)
                                Spacer()
                                Text(financialModel.solarSaving.formattedAmount(appSettings.currencySymbol))
                                    .accessibilityLabel(financialModel.solarSaving.accessibilityLabel(appSettings.currencySymbol))
                            }
                            if showCalculations {
                                CalculationBreakdownView(breakdown: financialModel.solarSavingBreakdown, decimalPlaces: appSettings.decimalPlaces)
                            }
                        }

                        HStack {
                            Text("total_benefit")
                                .accessibilityHidden(true)
                            Spacer()
                            Text(financialModel.total.formattedAmount(appSettings.currencySymbol))
                                .accessibilityLabel(financialModel.total.accessibilityLabel(appSettings.currencySymbol))
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
                       appSettings: .mock(selfSufficiencyEstimateMode: .net),
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
