//
//  SelfSufficiencyEstimateView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 29/06/2023.
//

import Energy_Stats_Core
import SwiftUI

@available(iOS 16.0, *)
struct SelfSufficiencyEstimateView: View {
    private let viewModel: StatsTabViewModel
    private let estimate: String?
    private let appTheme: AppTheme
    @Environment(\.colorScheme) var colorScheme

    init(viewModel: StatsTabViewModel, mode: SelfSufficiencyEstimateMode, appTheme: AppTheme) {
        self.viewModel = viewModel
        self.appTheme = appTheme

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
        ZStack(alignment: .topLeading) {
            Group {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color("highlight_box"), lineWidth: 1)
                    .background(Color("highlight_box").opacity(0.1))

                Text("Approximations")
                    .padding(2)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color("highlight_box"))
                    )
                    .font(.caption2)
                    .fontWeight(.bold)
                    .offset(x: 8, y: -8)
                    .foregroundColor(Color.white.opacity(colorScheme == .dark ? 0.8 : 1.0))
            }

            ZStack {
                VStack {
                    OptionalView(estimate) { estimate in
                        HStack {
                            Text("Self sufficiency")
                            Spacer()
                            Text(estimate)
                        }
                    }

                    if let home = viewModel.homeUsage {
                        HStack {
                            Text("Home usage")
                            Spacer()
                            EnergyText(amount: home, appTheme: appTheme, type: .selfSufficiency)
                        }
                    }
                }
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
        .padding()
    }
}

@available(iOS 16.0, *)
struct SelfSufficiencyEstimateView_Previews: PreviewProvider {
    static var previews: some View {
        SelfSufficiencyEstimateView(viewModel: StatsTabViewModel(networking: DemoNetworking(), configManager: PreviewConfigManager()),
                                    mode: .absolute,
                                    appTheme: AppTheme.mock())
    }
}
