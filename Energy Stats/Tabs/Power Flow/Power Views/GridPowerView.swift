//
//  GridPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct GridPowerView: View {
    let amount: Double
    let appSettings: AppSettings

    var body: some View {
        VStack {
            PowerFlowView(amount: amount, appSettings: appSettings, showColouredLines: true, type: .gridFlow)
            PylonView(lineWidth: 3)
                .frame(width: 45, height: 45)
        }
    }
}

#Preview {
    GridPowerView(amount: 0.4,
                  appSettings: AppSettings.mock())
}
