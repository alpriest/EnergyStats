//
//  PowerFlowView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Combine
import SwiftUI

struct PowerFlowView: View {
    private let amount: Double
    private let animationDuration: Double
    private let appTheme: LatestAppTheme
    private let showColouredLines: Bool

    init(amount: Double, appTheme: LatestAppTheme, showColouredLines: Bool) {
        self.amount = amount
        self.appTheme = appTheme
        self.showColouredLines = showColouredLines

        animationDuration = max(0.4, 2.7 - abs(amount))
    }

    var body: some View {
        ZStack(alignment: .center) {
            if isFlowing {
                ZStack {
                    if amount > 0 {
                        FlowingLine(direction: .down, animationDuration: animationDuration, color: lineColor)
                    } else {
                        FlowingLine(direction: .up, animationDuration: animationDuration, color: lineColor)
                    }

                    EnergyAmountView(amount: amount, decimalPlaces: appTheme.value.decimalPlaces)
                        .font(.footnote)
                        .bold()
                }
            } else {
                Line()
                    .stroke(lineColor, lineWidth: 4)
            }
        }
    }

    var lineColor: Color {
        if isFlowing && appTheme.value.showColouredLines && showColouredLines {
            if amount > 0 {
                return Color("lines_positive")
            } else {
                return Color("lines_negative")
            }
        } else {
            return Color("lines_notflowing")
        }
    }

    var isFlowing: Bool {
        amount.rounded(decimalPlaces: 2) != 0.0
    }
}

struct PowerFlowView_Previews: PreviewProvider {
    static var previews: some View {
        AdjustableView(config: MockConfig())
    }

    struct AdjustableView: View {
        @State private var amount: Double = 2.0
        @State private var visible = true
        let config: Config

        var body: some View {
            VStack {
                Color.clear.overlay(
                    Group {
                        if visible {
                            PowerFlowView(amount: amount, appTheme: CurrentValueSubject(AppTheme.mock()), showColouredLines: true)
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
}
