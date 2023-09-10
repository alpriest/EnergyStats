//
//  SolarPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 18/03/2023.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct SolarPowerViewModel {
    let solar: Double
    let generation: Double
    let earnings: EarningsViewModel
}

struct SolarPowerView: View {
    private let appTheme: AppTheme
    private let viewModel: SolarPowerViewModel

    init(appTheme: AppTheme, viewModel: SolarPowerViewModel) {
        self.appTheme = appTheme
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if appTheme.showTotalYield {
                HStack(spacing: 0) {
                    (Text("Yield today") + Text(" ")).accessibilityHidden(true)
                    EnergyText(amount: viewModel.generation, appTheme: appTheme, type: .totalYield)
                }
            }

            if appTheme.showEarnings {
                EarningsView(viewModel: viewModel.earnings)
                    .padding(.bottom, 4)
            }

            switch viewModel.solar {
            case 0.001 ..< appTheme.solarDefinitions.breakPoint1:
                SunView(solar: viewModel.solar, glowing: false, glowColor: .clear, sunColor: Color("Sun"))
                    .frame(width: 40, height: 40)
            case appTheme.solarDefinitions.breakPoint1 ..< appTheme.solarDefinitions.breakPoint2:
                SunView(solar: viewModel.solar, glowing: true, glowColor: .yellow.opacity(0.3), sunColor: Color("Sun"))
                    .frame(width: 40, height: 40)
            case appTheme.solarDefinitions.breakPoint2 ..< appTheme.solarDefinitions.breakPoint3:
                SunView(solar: viewModel.solar, glowing: true, glowColor: Color("Sun"), sunColor: .orange)
                    .frame(width: 40, height: 40)
            case appTheme.solarDefinitions.breakPoint3 ..< 500:
                SunView(solar: viewModel.solar, glowing: true, glowColor: .orange, sunColor: .red)
                    .frame(width: 40, height: 40)
            default:
                SunView(solar: viewModel.solar, glowing: false, glowColor: .clear, sunColor: Color("Sun_Zero"))
                    .frame(width: 40, height: 40)
            }

            PowerFlowView(amount: viewModel.solar, appTheme: appTheme, showColouredLines: false, type: .solarFlow)
        }
    }
}

struct SolarPowerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AdjustableView(appTheme: .mock(), config: MockConfig(), maximum: 5.0)

            HStack {
                SolarPowerView(
                    appTheme: AppTheme.mock(),
                    viewModel: SolarPowerViewModel(solar: 0, generation: 0, earnings: .any())
                )
                SolarPowerView(
                    appTheme: AppTheme.mock(),
                    viewModel: SolarPowerViewModel(solar: 0.5, generation: 1.5, earnings: .any())
                )
                SolarPowerView(
                    appTheme: AppTheme.mock(),
                    viewModel: SolarPowerViewModel(solar: 1.5, generation: 1.5, earnings: .any())
                )
                SolarPowerView(
                    appTheme: AppTheme.mock(),
                    viewModel: SolarPowerViewModel(solar: 2.5, generation: 4.5, earnings: .any())
                )
                SolarPowerView(
                    appTheme: AppTheme.mock(),
                    viewModel: SolarPowerViewModel(solar: 3.5, generation: 9.5, earnings: .any())
                )
            }
        }
    }
}

struct AdjustableView: View {
    @State private var amount: Double = 3.0
    @State private var visible = true
    let appTheme: AppTheme
    let config: Config
    let maximum: Double

    var body: some View {
        VStack {
            Color.clear.overlay(
                SolarPowerView(appTheme: appTheme, viewModel: SolarPowerViewModel(solar: amount, generation: 8.5, earnings: .any()))
            ).frame(height: 100)

            Slider(value: $amount, in: 0 ... maximum, step: 0.1, label: {
                Text("kWH")
            }, onEditingChanged: { _ in
                visible.toggle()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    visible.toggle()
                }
            })
        }
    }
}
