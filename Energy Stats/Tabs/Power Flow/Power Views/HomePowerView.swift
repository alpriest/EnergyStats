//
//  HomePowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Combine
import SwiftUI
import Energy_Stats_Core

struct HomePowerView: View {
    let amount: Double
    let iconFooterSize: CGSize
    let appTheme: AppTheme

    var body: some View {
        VStack {
            PowerFlowView(amount: amount, appTheme: appTheme, showColouredLines: false)
            Image(systemName: "house.fill")
                .font(.system(size: 44))
                .frame(width: 45, height: 45)
            Color.clear.frame(width: iconFooterSize.width, height: iconFooterSize.height)
        }
    }
}

struct HomePowerView_Previews: PreviewProvider {
    static var previews: some View {
        HomePowerView(amount: 1.05, iconFooterSize: CGSize(width: 32, height: 32),
                      appTheme: AppTheme.mock())
            .frame(width: 50, height: 220)
    }
}
