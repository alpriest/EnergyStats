//
//  ParametersGraphChartView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 11/09/2026.
//

import Charts
import Energy_Stats_Core
import SwiftUI

struct ParametersGraphChartView: View {
    let values: [ParameterGraphValue]

    var body: some View {
        Chart(values) {
            if $0.type.variable == Variable.solcastPredictionVariable.variable {
                LineMark(
                    x: .value("hour", $0.date),
                    y: .value("", $0.value),
                    series: .value("Title", $0.type.title(as: .snapshot))
                )
                .foregroundStyle($0.type.colour)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5], dashPhase: 0))
            } else {
                LineMark(
                    x: .value("hour", $0.date),
                    y: .value("", $0.value),
                    series: .value("Title", $0.type.title(as: .snapshot))
                )
                .foregroundStyle($0.type.colour)
            }
        }
    }
}
