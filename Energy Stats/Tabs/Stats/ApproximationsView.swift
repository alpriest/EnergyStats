//
//  ApproximationsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/08/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ApproximationsView: View {
    @ObservedObject var viewModel: StatsTabViewModel
    let appTheme: AppTheme
    @Environment(\.colorScheme) var colorScheme

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
                        SelfSufficiencyEstimateView(viewModel: viewModel, mode: appTheme.selfSufficiencyEstimateMode)
                    }

                    if let home = viewModel.homeUsage {
                        HStack {
                            Text("Home usage")
                            Spacer()
                            EnergyText(amount: home, appTheme: appTheme, type: .selfSufficiency)
                        }
                    }

                    if let solarUsage = viewModel.solarUsage {
                        HStack {
                            Text("Solar consumption")
                            Spacer()
                            EnergyText(amount: solarUsage, appTheme: appTheme, type: .selfSufficiency)
                        }
                    }
                }.padding()
            }
        }
        .padding(.top)
    }
}

#if DEBUG
struct ApproximationsView_Previews: PreviewProvider {
    static var previews: some View {
        ApproximationsView(viewModel: StatsTabViewModel(networking: DemoNetworking(),
                                                        configManager: PreviewConfigManager()),
                           appTheme: .mock(selfSufficiencyEstimateMode: .net))
    }
}
#endif
