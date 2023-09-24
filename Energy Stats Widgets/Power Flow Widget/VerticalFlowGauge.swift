//
//  VerticalFlowGaugeRow.swift
//  WidgetExtension
//
//  Created by Alistair Priest on 15/06/2023.
//

import Energy_Stats_Core
import SwiftUI

struct VerticalFlowGauge<Content: View>: View {
    let image: () -> Content
    let amount: Double
    let showColouredLines: Bool
    let appTheme: AppTheme

    var body: some View {
        VStack {
            image()
                .frame(width: 22, height: 20)

            EnergyAmountView(
                amount: amount,
                decimalPlaces: appTheme.decimalPlaces,
                backgroundColor: appTheme.lineColor(for: amount, showColour: showColouredLines),
                textColor: appTheme.textColor(for: amount, showColour: showColouredLines),
                appTheme: appTheme
            )
            .frame(maxWidth: .infinity)
            .font(.caption)
        }
    }
}

struct FlowGaugeRow_Previews: PreviewProvider {
    static var previews: some View {
        VerticalFlowGauge(
            image: {
                Text("hi")
            },
            amount: 2.0,
            showColouredLines: true,
            appTheme: .mock()
        )
    }
}
