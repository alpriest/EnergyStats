//
//  HomePowerFooterView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/09/2023.
//

import Energy_Stats_Core
import SwiftUI

struct HomePowerFooterView: View {
    let amount: Double
    let appSettings: AppSettings

    var body: some View {
        VStack(alignment: .center) {
            if appSettings.showHomeTotalOnPowerFlow {
                EnergyText(amount: amount, appSettings: appSettings, type: .homeUsage)
                Text("Usage today")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(Color("text_dimmed"))
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HomePowerFooterView(amount: 1.0,
                        appSettings: .mock())
}
