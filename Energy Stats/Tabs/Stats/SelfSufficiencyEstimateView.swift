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
    @Environment(\.colorScheme) var colorScheme

    init(_ viewModel: ApproximationsViewModel, mode: SelfSufficiencyEstimateMode) {
        self.viewModel = viewModel

        switch mode {
        case .off:
            self.estimate = nil
        case .absolute:
            self.estimate = viewModel.absoluteSelfSufficiencyEstimate
        case .net:
            self.estimate = viewModel.netSelfSufficiencyEstimate
        }
    }

    var body: some View {
        OptionalView(estimate) { estimate in
            HStack {
                Text("Self sufficiency")
                Spacer()
                Text(estimate)
            }
        }
    }
}

@available(iOS 16.0, *)
struct SelfSufficiencyEstimateView_Previews: PreviewProvider {
    static var previews: some View {
        SelfSufficiencyEstimateView(ApproximationsViewModel.any(),
                                    mode: .absolute)
    }
}

extension ApproximationsViewModel {
    static func any() -> ApproximationsViewModel {
        ApproximationsViewModel(
            netSelfSufficiencyEstimate: "95%",
            absoluteSelfSufficiencyEstimate: "100%",
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
