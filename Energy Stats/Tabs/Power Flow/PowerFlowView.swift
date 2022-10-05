//
//  PowerFlowView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import SwiftUI

struct PowerFlowView: View {
    private let amount: Double
    private let animationDuration: Double

    init(amount: Double) {
        self.amount = amount
        animationDuration = max(0.4, 2.5 - abs(amount))
    }

    var body: some View {
        ZStack(alignment: .center) {
            if isNotFlowing {
                Line()
                    .stroke(Color("lines"), lineWidth: 4)
            } else {
                ZStack {
                    if amount > 0 {
                        FlowingLine(direction: .down, animationDuration: animationDuration)
                    } else {
                        FlowingLine(direction: .up, animationDuration: animationDuration)
                    }

                    EnergyAmountView(amount: amount)
                        .font(.footnote)
                        .bold()
                }
            }
        }
    }

    var isNotFlowing: Bool {
        amount.rounded(decimalPlaces: 2) == 0.0
    }
}

struct PowerFlowView_Previews: PreviewProvider {
    static var previews: some View {
        AdjustableView()
    }
}

struct AdjustableView: View {
    @State private var amount: Double = 2.0
    @State private var visible = true

    var body: some View {
        VStack {
            Color.clear.overlay(
                Group {
                    if visible {
                        PowerFlowView(amount: amount)
                    }
                }
            ).frame(height: 100)

            Slider(value: $amount, in: 0 ... 5.0, step: 0.1, label: {
                Text("kWH")
            }, onEditingChanged: { _ in
                visible.toggle()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    visible.toggle()
                }
            })

            Text(amount, format: .number)

            Button {
                visible.toggle()
            } label: {
                Text("Toggle")
            }
        }
    }
}
