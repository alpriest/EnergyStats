//
//  SolarStringsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/03/2024.
//

import Energy_Stats_Core
import SwiftUI

struct LabelWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let nextValue = nextValue()

        guard nextValue > value else { return }

        value = nextValue
    }
}

struct SolarStringsView: View {
    @State var pvLabelWidth: CGFloat = 100
    @ObservedObject var viewModel: LoadedPowerFlowViewModel
    let appSettings: AppSettings

    var body: some View {
        if (appSettings.powerFlowStrings.enabled || appSettings.ct2DisplayMode == .asPowerString) && viewModel.displayStrings.count > 0 {
            VStack(alignment: .leading) {
                ForEach(viewModel.displayStrings) { pvString in
                    HStack {
                        Text(pvString.displayName(settings: appSettings.powerFlowStrings))
                            .background(LabelWidthBackgroundSizeReader())
                            .frame(width: self.pvLabelWidth, alignment: .leading)
                            .onPreferenceChange(LabelWidthPreferenceKey.self, perform: { value in
                                DispatchQueue.main.async {
                                    pvLabelWidth = value
                                }
                            })

                        PowerText(amount: pvString.amount, appSettings: appSettings, type: .solarFlow)

                        if appSettings.showTotalYieldOnPowerFlow {
                            EnergyText(
                                amount: viewModel.todaysGeneration?.estimatedTotal(string: pvString.stringType),
                                appSettings: appSettings,
                                type: .solarStringTotal,
                                decimalPlaceOverride: 1,
                                prefix: "(",
                                suffix: ")"
                            )
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(pvString.displayName(settings: appSettings.powerFlowStrings) + " " + AmountType.solarString.accessibilityLabel(amount: pvString.amount, amountWithUnit: pvString.amount.kWh(2)))
                }
                .foregroundStyle(Color.textNotFlowing)
            }
            .font(.caption)
            .padding(2)
            .background(Color.linesNotFlowing)
        }
    }
}

struct LabelWidthBackgroundSizeReader: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: LabelWidthPreferenceKey.self, value: geometry.size.width)
        }
        .scaledToFill()
    }
}

#Preview {
    let appSettings = AppSettings.mock().copy(powerFlowStrings: PowerFlowStringsSettings.none.copy(enabled: true, pv1Name: "Front", pv2Name: "To"))
    SolarStringsView(
        viewModel: .any(appSettings: appSettings),
        appSettings: appSettings
    )
}
