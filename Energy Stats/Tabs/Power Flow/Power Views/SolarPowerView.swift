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
}

struct SolarPowerView: View {
    private let appSettings: AppSettings
    private let viewModel: SolarPowerViewModel

    init(appSettings: AppSettings, viewModel: SolarPowerViewModel) {
        self.appSettings = appSettings
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            ZStack {
                SunView(solar: viewModel.solar, solarDefinitions: appSettings.solarDefinitions)
                    .frame(width: 40, height: 40)
            }

            PowerFlowView(amount: viewModel.solar, appSettings: appSettings, showColouredLines: false, type: .solarFlow)
        }
    }
}

struct SolarPowerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AdjustableView(appSettings: .mock(), config: MockConfig(), maximum: 5.0, thresholds: [])

            HStack {
                SolarPowerView(
                    appSettings: AppSettings.mock(),
                    viewModel: SolarPowerViewModel(solar: 0)
                )
                SolarPowerView(
                    appSettings: AppSettings.mock(),
                    viewModel: SolarPowerViewModel(solar: 0.5)
                )
                SolarPowerView(
                    appSettings: AppSettings.mock(),
                    viewModel: SolarPowerViewModel(solar: 1.5)
                )
                SolarPowerView(
                    appSettings: AppSettings.mock(),
                    viewModel: SolarPowerViewModel(solar: 2.5)
                )
                SolarPowerView(
                    appSettings: AppSettings.mock(),
                    viewModel: SolarPowerViewModel(solar: 3.5)
                )
            }
        }
    }
}

struct AdjustableView: View {
    @State private var amount: Double = 3.0
    @State private var visible = true
    let appSettings: AppSettings
    let config: Config
    let maximum: Double
    let thresholds: [Double]
    private let haptic = UISelectionFeedbackGenerator()

    init(appSettings: AppSettings, config: Config, maximum: Double, thresholds: [Double]) {
        self.appSettings = appSettings
        self.config = config
        self.maximum = maximum
        self.thresholds = thresholds
        haptic.prepare()
    }

    var body: some View {
        VStack {
            Color.clear.overlay(
                SolarPowerView(appSettings: appSettings, viewModel: SolarPowerViewModel(solar: amount))
            ).frame(height: 100)

            Slider(value: $amount, in: 0 ... maximum, step: 0.1, label: {
                Text("kWH")
            }, onEditingChanged: { _ in
                visible.toggle()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    visible.toggle()
                }
            })
            .onChange(of: amount) { newValue in
                if thresholds.contains(newValue) {
                    haptic.selectionChanged()
                }
            }
        }
    }
}
