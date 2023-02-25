//
//  EnergyAmountView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/10/2022.
//

import SwiftUI

struct EnergyAmountView: View {
    let amount: Double
    @State private var asKW = true

    var body: some View {
        Color.clear.overlay(
            Group {
                if asKW {
                    Text(amount.kW())
                } else {
                    Text(amount.w())
                }
            }
            .padding(1)
            .background(Color(uiColor: UIColor.systemBackground))
        ).onTapGesture {
            asKW.toggle()
        }
    }
}

struct EnergyAmountView_Previews: PreviewProvider {
    static var previews: some View {
        EnergyAmountView(amount: 0.310)
    }
}
