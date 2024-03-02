//
//  SolarStringsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/03/2024.
//

import Energy_Stats_Core
import SwiftUI

struct MaxWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let nextValue = nextValue()

        guard nextValue > value else { return }

        value = nextValue
    }
}

struct SolarStringsView: View {
    @State var maxLabelWidth: CGFloat = 100
    let viewModel: HomePowerFlowViewModel
    let appSettings: AppSettings

    var body: some View {
        VStack(alignment: .leading) {
            if appSettings.powerFlowStrings.enabled, viewModel.solar.isFlowing() {
                ForEach(viewModel.solarStrings) { pvString in
                    HStack {
                        Text(pvString.displayName(settings: appSettings.powerFlowStrings))
                            .background(BackgroundSizeReader())
                            .onPreferenceChange(MaxWidthPreferenceKey.self, perform: { value in
                                maxLabelWidth = value
                            })
                            .frame(width: self.maxLabelWidth, alignment: .leading)

                        PowerText(amount: pvString.amount, appSettings: appSettings, type: .solarFlow)
                    }
                }
                .foregroundStyle(Color.textNotFlowing)
            }
        }
        .padding(2)
        .background(Color.linesNotFlowing)
        .font(.caption)
    }
}

struct BackgroundSizeReader: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: MaxWidthPreferenceKey.self, value: geometry.size.width)
        }
        .scaledToFill()
    }
}

#Preview {
    SolarStringsView(
        viewModel: .any(),
        appSettings: .mock().copy(powerFlowStrings: PowerFlowStringsSettings.none.copy(enabled: true, pv1Name: "Front", pv2Name: "To"))
    )
}
