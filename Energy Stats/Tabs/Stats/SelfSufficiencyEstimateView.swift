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

    init(_ viewModel: ApproximationsViewModel, mode: SelfSufficiencyEstimateMode, showCalculations: Bool) {
        self.viewModel = viewModel
        self.showCalculations = showCalculations

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
                    CalculationBreakdownView(breakdown: CalculationBreakdown(formula: calculations.formula, calculation: calculations.calculation))
                }
            }
        }
    }
}

@available(iOS 16.0, *)
struct SelfSufficiencyEstimateView_Previews: PreviewProvider {
    static var previews: some View {
        SelfSufficiencyEstimateView(ApproximationsViewModel.any(),
                                    mode: .absolute,
                                    showCalculations: true)
    }
}

extension ApproximationsViewModel {
    static func any() -> ApproximationsViewModel {
        ApproximationsViewModel(
            netSelfSufficiencyEstimate: "95%",
            netSelfSufficiencyEstimateCalculationBreakdown: CalculationBreakdown(formula: "x * b", calculation: "1 * 5"),
            absoluteSelfSufficiencyEstimate: "100%",
            absoluteSelfSufficiencyEstimateCalculationBreakdown: CalculationBreakdown(formula: "x * b / c", calculation: "1 * 5 / 8.9"),
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
