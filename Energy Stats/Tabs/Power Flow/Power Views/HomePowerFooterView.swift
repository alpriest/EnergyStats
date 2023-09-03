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
    let appTheme: AppTheme

    var body: some View {
        VStack(alignment: .center) {
            if appTheme.showHomeTotalOnPowerFlow {
                EnergyText(amount: amount, appTheme: appTheme, type: .homeUsage)
                Text("Usage today")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(Color("text_dimmed"))
            }
        }
    }
}

struct HomePowerFooterView_Previews: PreviewProvider {
    static var previews: some View {
        HomePowerFooterView(amount: 1.0,
                            appTheme: .mock())
    }
}
