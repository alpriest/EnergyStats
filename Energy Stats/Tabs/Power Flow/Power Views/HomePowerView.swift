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
    let total: Double
    let iconFooterSize: CGSize
    let appTheme: AppTheme

    var body: some View {
        VStack {
            PowerFlowView(amount: amount, appTheme: appTheme, showColouredLines: false, type: .homeFlow)

            Image(systemName: "house.fill")
                .font(.system(size: 44))
                .frame(width: 45, height: 45)
                .accessibilityHidden(true)
                .padding(.bottom, 1)

            VStack {
                if appTheme.showHomeTotal {
                    EnergyText(amount: total, appTheme: appTheme, type: .homeUsage)
                    Text("Usage today")
                        .font(.caption)
                        .foregroundColor(Color("text_dimmed"))
                }
            }
            .frame(width: iconFooterSize.width, height: iconFooterSize.height)
        }
    }
}

struct HomePowerView_Previews: PreviewProvider {
    static var previews: some View {
        HomePowerView(amount: 1.05,
                      total: 4.5,
                      iconFooterSize: CGSize(width: 32, height: 32),
                      appTheme: AppTheme.mock())
            .frame(width: 50, height: 220)
    }
}
