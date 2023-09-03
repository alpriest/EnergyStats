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
    let appTheme: AppTheme

    var body: some View {
        VStack {
            PowerFlowView(amount: amount, appTheme: appTheme, showColouredLines: true, type: .gridFlow)
            PylonView(lineWidth: 3)
                .frame(width: 45, height: 45)
        }
    }
}

struct GridPowerView_Previews: PreviewProvider {
    static var previews: some View {
        GridPowerView(amount: 0.4,
                      appTheme: AppTheme.mock())
    }
}
