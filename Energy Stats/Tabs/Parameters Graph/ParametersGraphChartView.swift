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

    private var validValues: [ParameterGraphValue] {
        values.filter { $0.value.isFinite && $0.date.timeIntervalSinceReferenceDate.isFinite }
    }

    @ViewBuilder
    var body: some View {
        if validValues.isEmpty {
            Color.clear
        } else {
            chart
        }
    }

    private var chart: some View {
        Chart(validValues) {
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
            AxisMarks(values: .stride(by: .hour, count: Swift.max(stride, 1))) { value in
                if let date = value.as(Date.self) {
                    AxisTick(centered: false)
                    AxisValueLabel(anchor: .leading) {
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
