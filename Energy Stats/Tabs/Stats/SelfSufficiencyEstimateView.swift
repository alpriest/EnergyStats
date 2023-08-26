//
//  SelfSufficiencyEstimateView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 29/06/2023.
//

import Energy_Stats_Core
import SwiftUI

struct SelfSufficiencyEstimateView: View {
    private let viewModel: StatsTabViewModel
    private let estimate: String?
    @Environment(\.colorScheme) var colorScheme

    init(viewModel: StatsTabViewModel, mode: SelfSufficiencyEstimateMode) {
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
        SelfSufficiencyEstimateView(viewModel: StatsTabViewModel(networking: DemoNetworking(), configManager: PreviewConfigManager()),
                                    mode: .absolute)
    }
}
