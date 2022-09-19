//
//  PowerFlowView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import SwiftUI

struct PowerFlowView: View {
    let amount: Double

    var body: some View {
        ZStack(alignment: .center) {
            if isFlowing {
                Line()
                    .stroke(Color("lines"), lineWidth: 4)
            } else {
                ZStack {
                    if amount > 0 {
                        DirectionalArrow(direction: .down, animationDuration: animationDuration)
                    } else {
                        DirectionalArrow(direction: .up, animationDuration: animationDuration)
                    }

                    Text(amount.kW())
                        .font(.footnote)
                        .bold()
                }
            }
        }
    }

    var animationDuration: Double {
        max(0.4, 2.5 - abs(amount))
    }

    var isFlowing: Bool {
        amount.rounded(decimalPlaces: 2) == 0.0
    }
}

struct PowerFlowView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            PowerFlowView(amount: 2.0)
                .background(Color.red)

            PowerFlowView(amount: 0.001)
                .background(Color.red)

            PowerFlowView(amount: -4.5)
                .background(Color.red)
        }
    }
}
