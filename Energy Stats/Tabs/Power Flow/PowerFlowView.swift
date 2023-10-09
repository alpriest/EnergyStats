//
//  PowerFlowView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct PowerFlowView<S: Shape>: View {
    private let amount: Double
    private let animationDuration: Double
    private let appTheme: AppTheme
    private let showColouredLines: Bool
    private let type: AmountType
    private let shape: S
    private let showAmount: Bool

    init(amount: Double, appTheme: AppTheme, showColouredLines: Bool, type: AmountType, shape: S = Line(), showAmount: Bool = true) {
        self.amount = amount
        self.appTheme = appTheme
        self.showColouredLines = showColouredLines
        self.type = type
        self.shape = shape
        self.showAmount = showAmount

        animationDuration = max(0.4, 2.7 - abs(amount))
    }

    var body: some View {
        ZStack(alignment: .center) {
            if isFlowing {
                ZStack {
                    if amount > 0 {
                        FlowingLine(direction: .down, animationDuration: animationDuration, color: lineColor, shape: shape)
                    } else {
                        FlowingLine(direction: .up, animationDuration: animationDuration, color: lineColor, shape: shape)
                    }

                    if showAmount {
                        PowerAmountView(amount: amount, backgroundColor: lineColor, textColor: textColor, appTheme: appTheme, type: type)
                            .font(.body.bold())
                    }
                }
            } else {
                Line()
                    .stroke(lineColor, lineWidth: 4)
            }
        }
        .clipped()
    }

    var lineColor: Color {
        if isFlowing && appTheme.showColouredLines && showColouredLines {
            if amount > 0 {
                return Color("lines_positive")
            } else {
                return Color("lines_negative")
            }
        } else {
            return Color("lines_notflowing")
        }
    }

    var textColor: Color {
        if isFlowing && appTheme.showColouredLines && showColouredLines {
            if amount > 0 {
                return Color("text_positive")
            } else {
                return Color("text_negative")
            }
        } else {
            return Color("text_notflowing")
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
                            PowerFlowView(amount: amount, appTheme: AppTheme.mock(), showColouredLines: true, type: .solarFlow)
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
