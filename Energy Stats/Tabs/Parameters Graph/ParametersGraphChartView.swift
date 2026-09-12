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
    let xScale: ClosedRange<Date>
    let truncateYAxis: Bool
    let stride: Int
    let unit: String?

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
        .chartPlotStyle { content in
            content.background(Color.gray.gradient.opacity(0.04))
        }
        .chartXScale(domain: xScale)
        .chartYScale(domain: .automatic(includesZero: !truncateYAxis))
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: stride)) { value in
                if let date = value.as(Date.self) {
                    AxisTick(centered: false)
                    AxisValueLabel(centered: false) {
                        Text(date, format: .dateTime.hour())
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                if let amount = value.as(Double.self) {
                    AxisGridLine()
                    AxisValueLabel(multiLabelAlignment: .trailing) {
                        if let unit {
                            Text("\(amount, format: .number) \(unit)")
                        } else {
                            Text("\(amount, format: .number)")
                        }
                    }
                }
            }
        }
    }
}
