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
    let appTheme: AppTheme

    var body: some View {
        VStack {
            PowerFlowView(amount: amount, appTheme: appTheme, showColouredLines: false, type: .homeFlow)

            Image(systemName: "house.fill")
                .resizable()
                .frame(width: 45, height: 45)
                .accessibilityHidden(true)
                .padding(.bottom, 1)
        }
    }
}

struct HomePowerView_Previews: PreviewProvider {
    static var previews: some View {
        HomePowerView(amount: 1.05,
                      appTheme: AppTheme.mock())
            .frame(width: 50, height: 220)
    }
}
