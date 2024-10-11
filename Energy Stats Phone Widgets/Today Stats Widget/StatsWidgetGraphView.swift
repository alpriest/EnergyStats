//
//  StatsWidgetGraphView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/10/2024.
//

import Charts
import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct StatsWidgetGraphView: View {
    let home: [Double]?
    let gridImport: [Double]?
    let gridExport: [Double]?
    let batteryCharge: [Double]?
    let batteryDischarge: [Double]?
    let lastUpdated: Date

    var body: some View {
        VStack {
            Grid(alignment: .leading) {
                labelledAmount("Home", amount: home, type: .loads)
                labelledAmount("Grid Import", amount: gridImport, type: .gridConsumption)
                labelledAmount("Grid Export", amount: gridExport, type: .feedIn)
                labelledAmount("Battery Charge", amount: batteryCharge, type: .chargeEnergyToTal)
                labelledAmount("Battery Discharge", amount: batteryDischarge, type: .dischargeEnergyToTal)
            }.font(.caption)

            Text(lastUpdated, format: .dateTime)
                .font(.system(size: 8.0, weight: .light))
        }
    }

    private func labelledAmount(_ label: String, amount: [Double]?, type: ReportVariable) -> some View {
        OptionalView(amount) { values in
            GridRow {
                Text(label)
                Text(values.total().kWh(2))
                    .monospacedDigit()

                Chart(Array(values.enumerated()), id: \.offset) {
                    LineMark(
                        x: .value("hour", $0.0),
                        y: .value("kWh", $0.1)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .foregroundStyle(type.colour)
                }
                .chartPlotStyle { content in
                    content.background(Color.gray.gradient.opacity(0.07))
                }
                .chartXScale(domain: 0...24)
                .chartLegend(.hidden)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 14)
            }
            .padding(.bottom, 2)
        }
    }
}

extension Array where Element == Double {
    func total() -> Double {
        reduce(0, +)
    }
}

struct StatsGraphView_Previews: PreviewProvider {
    static var previews: some View {
        StatsWidgetGraphView(
            home: [0.0, 0.5, 0.9, 1.2, 1.5, 1.8, 1.3, 0.7, 0.3, 1.0, 1.6, 0.2],
            gridImport: [2.0, 1.9, 1.8, 0.3, 0.5, 0.7, 1.0, 1.2, 1.7, 0.8, 1.5, 0.6],
            gridExport: [1.0, 1.2, 1.8, 0.4, 0.9, 0.7, 1.3, 1.5, 0.2, 1.1, 1.9, 0.6],
            batteryCharge: [2.4, 1.6, 0.9, 0.2, 1.3, 1.9, 0.7, 1.1, 0.5, 1.8, 1.0, 0.4],
            batteryDischarge: [0.9, 0.2, 1.3, 1.5, 0.7, 0.8, 1.6, 0.3, 0.6, 1.9, 0.4, 1.2],
            lastUpdated: .now
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}
