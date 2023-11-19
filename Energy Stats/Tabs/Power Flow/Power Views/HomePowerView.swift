//
//  HomePowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct HomePowerView: View {
    let amount: Double
    let appSettings: AppSettings

    var body: some View {
        VStack {
            PowerFlowView(amount: amount, appSettings: appSettings, showColouredLines: false, type: .homeFlow)

            Image(systemName: "house.fill")
                .resizable()
                .frame(width: 50, height: 45)
                .accessibilityHidden(true)
                .padding(.bottom, 1)
        }
    }
}

#Preview {
    HomePowerView(amount: 1.05,
                  appSettings: AppSettings.mock())
        .frame(width: 50, height: 220)
}
