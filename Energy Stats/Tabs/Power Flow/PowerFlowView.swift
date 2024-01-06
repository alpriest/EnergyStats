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
    private let appSettings: AppSettings
    private let showColouredLines: Bool
    private let type: AmountType
    private let shape: S
    private let showAmount: Bool

    init(amount: Double, appSettings: AppSettings, showColouredLines: Bool, type: AmountType, shape: S = Line(), showAmount: Bool = true) {
        self.amount = amount
        self.appSettings = appSettings
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
                        PowerAmountView(amount: amount, backgroundColor: lineColor, textColor: textColor, appSettings: appSettings, type: type)
                            .font(.body.bold())
                    }
                }
            } else {
                shape
                    .stroke(lineColor, lineWidth: 4)
            }
        }
        .clipped()
    }

    var lineColor: Color {
        if isFlowing && appSettings.showColouredLines && showColouredLines {
            if amount > 0 {
                return Color.linesPositive
            } else {
                return Color.linesNegative
            }
        } else {
            return .linesNotFlowing
        }
    }

    var textColor: Color {
        if isFlowing && appSettings.showColouredLines && showColouredLines {
            if amount > 0 {
                return Color.textPositive
            } else {
                return Color.textNegative
            }
        } else {
            return Color.textNotFlowing
        }
    }

    var isFlowing: Bool {
        amount.rounded(decimalPlaces: 2) != 0.0
    }
}

#Preview {
    return AdjustableView(config: MockConfig())

    struct AdjustableView: View {
        @State private var amount: Double = 2.0
        @State private var visible = true
        let config: Config

        var body: some View {
            VStack {
                Color.clear.overlay(
                    Group {
                        if visible {
                            PowerFlowView(amount: amount, appSettings: AppSettings.mock(), showColouredLines: true, type: .solarFlow)
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
                    Text(verbatim: "Toggle")
                }
            }
        }
    }
}
