//
//  EnergyAmountView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/10/2022.
//

import SwiftUI

struct EnergyAmountView: View {
    let amount: Double
    let decimalPlaces: Int
    let backgroundColor: Color
    let textColor: Color
    @State private var asKW = true

    var body: some View {
        Color.clear.overlay(
            Group {
                if asKW {
                    Text(amount.kW(decimalPlaces))
                } else {
                    Text(amount.w())
                }
            }
            .padding(3)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(3)
        ).onTapGesture {
            asKW.toggle()
        }
    }
}

struct EnergyAmountView_Previews: PreviewProvider {
    static var previews: some View {
        EnergyAmountView(amount: 0.310, decimalPlaces: 3, backgroundColor: .red, textColor: .black)
    }
}
