//
//  SelfSufficiencyEstimateView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 29/06/2023.
//

import Energy_Stats_Core
import SwiftUI

struct SelfSufficiencyEstimateView: View {
    private let viewModel: ApproximationsViewModel
    private let estimate: String?
    private let showCalculations: Bool
    private let calculations: CalculationBreakdown?
    @Environment(\.colorScheme) var colorScheme
    private let decimalPlaces: Int

    init(_ viewModel: ApproximationsViewModel, mode: SelfSufficiencyEstimateMode, showCalculations: Bool, decimalPlaces: Int) {
        self.viewModel = viewModel
        self.showCalculations = showCalculations
        self.decimalPlaces = decimalPlaces

        switch mode {
        case .off:
            self.estimate = nil
            self.calculations = nil
        case .absolute:
            self.estimate = viewModel.absoluteSelfSufficiencyEstimate
            self.calculations = viewModel.absoluteSelfSufficiencyEstimateCalculationBreakdown
        case .net:
            self.estimate = viewModel.netSelfSufficiencyEstimate
            self.calculations = viewModel.netSelfSufficiencyEstimateCalculationBreakdown
        }
    }

    var body: some View {
        OptionalView(estimate) { estimate in
            VStack(spacing: 2) {
                HStack {
                    Text("Self sufficiency")
                    Spacer()
                    Text(estimate)
                }

                if showCalculations, let calculations = calculations {
                    CalculationBreakdownView(
                        breakdown: CalculationBreakdown(formula: calculations.formula, calculation: calculations.calculation),
                        decimalPlaces: decimalPlaces
                    )
                }
            }
        }
    }
}

#Preview {
    SelfSufficiencyEstimateView(ApproximationsViewModel.any(),
                                mode: .absolute,
                                showCalculations: true,
                                decimalPlaces: 3)
}

extension ApproximationsViewModel {
    static func any() -> ApproximationsViewModel {
        ApproximationsViewModel(
            netSelfSufficiencyEstimateValue: 0.95,
            netSelfSufficiencyEstimate: "95%",
            netSelfSufficiencyEstimateCalculationBreakdown: CalculationBreakdown(formula: "x * b", calculation: { _ in "1 * 5" }),
            absoluteSelfSufficiencyEstimateValue: 1.0,
            absoluteSelfSufficiencyEstimate: "100%",
            absoluteSelfSufficiencyEstimateCalculationBreakdown: CalculationBreakdown(formula: "x * b / c", calculation: { _ in "1 * 5 / 8.9" }),
            financialModel: nil,
            homeUsage: 4.5,
            totalsViewModel: .any()
        )
    }
}

extension TotalsViewModel {
    static func any() -> TotalsViewModel {
        TotalsViewModel(grid: 1.0, feedIn: 2.0, loads: 5.0, batteryCharge: 2.3, batteryDischarge: 1.2)
    }
}

struct SelfSufficiencyGraphVariable: Identifiable, Equatable, Hashable {
    let date: Date
    let value: Double
    var id: String { date.iso8601() }
}
