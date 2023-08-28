//
//  GridPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Combine
import SwiftUI
import Energy_Stats_Core

struct GridPowerView: View {
    let amount: Double
    let iconFooterHeight: Double
    let appTheme: AppTheme

    var body: some View {
        VStack {
            PowerFlowView(amount: amount, appTheme: appTheme, showColouredLines: true, type: .gridFlow)
            PylonView(lineWidth: 3)
                .frame(width: 45, height: 45)

            Color.clear.frame(height: iconFooterHeight)
        }
    }
}

struct GridPowerView_Previews: PreviewProvider {
    static var previews: some View {
        GridPowerView(amount: 0.4,
                      iconFooterHeight: 32,
                      appTheme: AppTheme.mock())
    }
}
