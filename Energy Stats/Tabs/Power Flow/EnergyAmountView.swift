//
//  EnergyAmountView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/10/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct EnergyAmountView: View {
    let amount: Double
    let decimalPlaces: Int
    let backgroundColor: Color
    let textColor: Color
    let appTheme: AppTheme

    var body: some View {
        Color.clear.overlay(
            Group {
                if appTheme.showInW {
                    Text(amount.w())
                } else {
                    Text(amount.kW(decimalPlaces))
                }
            }
            .padding(3)
            .padding(.horizontal, 4)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(3)
        )
    }
}

struct EnergyAmountView_Previews: PreviewProvider {
    static var previews: some View {
        EnergyAmountView(amount: 0.310, decimalPlaces: 3, backgroundColor: .red, textColor: .black, appTheme: AppTheme.mock())
    }
}
