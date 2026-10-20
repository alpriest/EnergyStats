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
    let displayStrings: [StringPower]
    let todaysGeneration: GenerationViewModel?
}

struct SolarPowerView: View {
    private let appSettings: AppSettings
    private let viewModel: SolarPowerViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(appSettings: AppSettings, viewModel: SolarPowerViewModel) {
        self.appSettings = appSettings
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            SunView(solar: viewModel.solar, solarDefinitions: appSettings.solarDefinitions)
                .frame(width: 40, height: 40)

            PowerFlowView(
                amount: viewModel.solar,
                appSettings: appSettings,
                showColouredLines: false,
                type: .solarFlow,
                verticalAlignment: VerticalConstraint.isConstrained(dynamicTypeSize: dynamicTypeSize, appSettings: appSettings) ? .top : .center,
                additionalAmountView: {
                    SolarStringsView(displayStrings: viewModel.displayStrings,
                                     todaysGeneration: viewModel.todaysGeneration,
                                     appSettings: appSettings)
                }
            )
        }
    }
}

struct SolarPowerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AdjustableView(appSettings: .mock(), maximum: 5.0, thresholds: [])

            HStack {
                SolarPowerView(
                    appSettings: AppSettings.mock(),
                    viewModel: SolarPowerViewModel(solar: 0, displayStrings: [], todaysGeneration: nil)
                )
                SolarPowerView(
                    appSettings: AppSettings.mock(),
                    viewModel: SolarPowerViewModel(solar: 0.5, displayStrings: [], todaysGeneration: nil)
                )
                SolarPowerView(
                    appSettings: AppSettings.mock(),
                    viewModel: SolarPowerViewModel(solar: 1.5, displayStrings: [], todaysGeneration: nil)
                )
                SolarPowerView(
                    appSettings: AppSettings.mock(),
                    viewModel: SolarPowerViewModel(solar: 2.5, displayStrings: [], todaysGeneration: nil)
                )
                SolarPowerView(
                    appSettings: AppSettings.mock(),
                    viewModel: SolarPowerViewModel(solar: 3.5, displayStrings: [], todaysGeneration: nil)
                )
            }
        }
    }
}

struct AdjustableView: View {
    @State private var amount: Double = 3.0
    @State private var visible = true
    let appSettings: AppSettings
    let maximum: Double
    let thresholds: [Double]
    private let haptic = UISelectionFeedbackGenerator()

    init(appSettings: AppSettings, maximum: Double, thresholds: [Double]) {
        self.appSettings = appSettings
        self.maximum = maximum
        self.thresholds = thresholds
        haptic.prepare()
    }

    var body: some View {
        VStack {
            Color.clear.overlay(
                SolarPowerView(appSettings: appSettings, viewModel: SolarPowerViewModel(solar: amount, displayStrings: [], todaysGeneration: nil))
            ).frame(height: 100)

            Slider(value: $amount, in: 0 ... maximum, step: 0.1, label: {
                Text("kWH")
            }, onEditingChanged: { _ in
                visible.toggle()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    visible.toggle()
                }
            })
            .onChange(of: amount) {
                if thresholds.contains(amount) {
                    haptic.selectionChanged()
                }
            }
        }
    }
}
