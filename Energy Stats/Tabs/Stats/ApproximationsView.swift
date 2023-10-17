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
    @State private var showSolarCalculation = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            Group {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color("highlight_box"), lineWidth: 1)
                    .background(Color("highlight_box").opacity(0.1))
                    .padding(1)

                Text("Approximations")
                    .padding(2)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color("highlight_box"))
                    )
                    .font(.caption2.weight(.bold))
                    .offset(x: 8, y: -8)
                    .foregroundColor(Color.white.opacity(colorScheme == .dark ? 0.8 : 1.0))
            }

            ZStack {
                VStack {
                    if appTheme.selfSufficiencyEstimateMode != .off {
                        SelfSufficiencyEstimateView(viewModel, mode: appTheme.selfSufficiencyEstimateMode)
                    }

                    if let home = viewModel.homeUsage {
                        HStack {
                            Text("Home usage")
                                .accessibilityElement(children: .ignore)
                            Spacer()
                            EnergyText(amount: home, appTheme: appTheme, type: .selfSufficiency)
                        }
                    }

                    if let totals = viewModel.totalsViewModel {
                        HStack {
                            Text("Solar generated")
                                .accessibilityElement(children: .ignore)
                            Spacer()
                            EnergyText(amount: totals.solar, appTheme: appTheme, type: .totalSolarGenerated)
                        }.onTapGesture {
                            withAnimation {
                                showSolarCalculation.toggle()
                            }
                        }

                        if showSolarCalculation {
                            CalculationBreakdownView(breakdown: totals.solarBreakdown)
                        }
                    }

                    if let financialModel = viewModel.financialModel {
                        HStack {
                            Text("Export income")
                            Spacer()
                            Text(financialModel.exportIncome.formattedAmount())
                        }

                        HStack {
                            Text("Grid import avoided")
                            Spacer()
                            Text(financialModel.solarSaving.formattedAmount())
                        }

                        HStack {
                            Text("Total benefit")
                            Spacer()
                            Text(financialModel.total.formattedAmount())
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

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color("highlight_box"), lineWidth: 1)
                .background(Color("highlight_box").opacity(0.1))

            VStack(alignment: .leading, spacing: 8) {
                Text(breakdown.formula)
                Text(breakdown.calculation)
            }
            .padding(5)
        }
        .font(.caption2)
        .padding(.bottom)
    }
}

#if DEBUG
struct ApproximationsView_Previews: PreviewProvider {
    static var previews: some View {
        ApproximationsView(viewModel: .any(),
                           appTheme: .mock(selfSufficiencyEstimateMode: .net))
    }
}
#endif

#Preview {
    CalculationBreakdownView(breakdown: CalculationBreakdown(
        formula: "max(0, batteryCharge - batteryDischarge - gridImport + home + gridExport)",
        calculation: "max(0, 7.6 - 7.4 - 4.9 + 9.4 + 3.1)"
    ))
}
