//
//  PowerFlowView.swift
//  PV Stats
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
                    DirectionalArrow(direction: amount > 0 ? .down : .up, animationDuration: animationDuration)

                    Text("\(String(format: "%0.3f", amount))kW")
                        .font(.footnote)
                }
            }
        }
    }

    var animationDuration: Double {
        max(0.3, 2.5 - amount)
    }

    var isFlowing: Bool {
        fabs(amount) == 0.0
    }
}

struct PowerFlowView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            PowerFlowView(amount: 2.0)
                .background(Color.red)

            PowerFlowView(amount: 0)
                .background(Color.red)
        }
    }
}
