//
//  TodaySolarGenerationWidgetGraphView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/10/2024.
//

import Charts
import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct TodaySolarGenerationWidgetGraphView: View {
    let PVEnergy: [Double]?
    let totalPVEnergy: Double?

    var body: some View {
        Grid(alignment: .leading) {
            labelledAmount("PV Generation", amounts: PVEnergy, total: totalPVEnergy, type: .pvEnergyTotal)
        }.font(.caption)
    }

    private func labelledAmount(_ label: String, amounts: [Double]?, total: Double?, type: ReportVariable) -> some View {
        Group {
            if let amounts, let total {
                VStack {
                    HStack {
                        Text(label)
                        Text(total.kWh(2))
                    }

                    Chart(Array(amounts.enumerated()), id: \.offset) {
                        LineMark(
                            x: .value("hour", $0.offset),
                            y: .value("kWh", $0.element)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 1))
                        .foregroundStyle(type.colour)
                    }
                    .chartPlotStyle { content in
                        content.background(Color.gray.gradient.opacity(0.07))
                    }
                    .chartXScale(domain: 0 ... 23)
                    .chartLegend(.hidden)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: 4)) { value in
                            if let intHour = value.as(Int.self) {
                                AxisTick()
                                AxisValueLabel {
                                    Text(hourLabel(for: intHour))
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .stride(by: 2)) { value in
                            if let doubleValue = value.as(Double.self) {
                                AxisValueLabel {
                                    Text(doubleValue, format: .number)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

func hourLabel(for hour: Int) -> String {
    let calendar = Calendar.current
    let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
    let formatter = DateFormatter()
    formatter.dateFormat = "ha" // e.g., "1AM", "2PM"
    return formatter.string(from: date).lowercased() // "1am", "2pm", etc.
}

struct TodaySolarGenerationWidgetGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let pvValues = [
            0.0, 0.0, 0.0, 0.0, // 12am–4am
            0.1, 0.4, 1.0, 2.2, // 4am–8am
            3.2, 3.8, 4.0, 3.8, // 8am–12pm
            3.5, 3.0, 2.4, 1.6, // 12pm–4pm
            1.0, 0.5, 0.2, 0.1, // 4pm–8pm
            0.0, 0.0, 0.0, 0.0 // 8pm–12am
        ]
        return TodaySolarGenerationWidgetGraphView(
            PVEnergy: pvValues,
            totalPVEnergy: pvValues.reduce(0, +)
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}
