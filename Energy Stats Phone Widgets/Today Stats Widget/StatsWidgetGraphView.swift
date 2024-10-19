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
    let totalHome: Double?
    let totalGridImport: Double?
    let totalGridExport: Double?
    let totalBatteryCharge: Double?
    let totalBatteryDischarge: Double?
    let lastUpdated: Date

    var body: some View {
        VStack {
            Grid(alignment: .leading) {
                labelledAmount("Home", amounts: home, total: totalHome, type: .loads)
                labelledAmount("Grid Import", amounts: gridImport, total: totalGridImport, type: .gridConsumption)
                labelledAmount("Grid Export", amounts: gridExport, total: totalGridExport, type: .feedIn)
                labelledAmount("Battery Charge", amounts: batteryCharge, total: totalBatteryCharge, type: .chargeEnergyToTal)
                labelledAmount("Battery Discharge", amounts: batteryDischarge, total: totalBatteryDischarge, type: .dischargeEnergyToTal)
            }.font(.caption)

            Text(lastUpdated, format: .dateTime)
                .font(.system(size: 8.0, weight: .light))
                .padding(.top, 10)
        }
    }

    private func labelledAmount(_ label: String, amounts: [Double]?, total: Double?, type: ReportVariable) -> some View {
        Group {
            if let amounts, let total {
                GridRow {
                    Text(label)
                    Text(total.kWh(2))
                        .monospacedDigit()

                    Chart(Array(amounts.enumerated()), id: \.offset) {
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
                    .chartXScale(domain: 0 ... 24)
                    .chartLegend(.hidden)
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(height: 14)
                }
                .padding(.bottom, 2)
            }
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
        let homeValues = [0.0, 0.5, 0.9, 1.2, 1.5, 1.8, 1.3, 0.7, 0.3, 1.0, 1.6, 0.2]
        let gridExportValues = [1.0, 1.2, 1.8, 0.4, 0.9, 0.7, 1.3, 1.5, 0.2, 1.1, 1.9, 0.6]
        let gridImportValues = [2.0, 1.9, 1.8, 0.3, 0.5, 0.7, 1.0, 1.2, 1.7, 0.8, 1.5, 0.6]
        let batteryChargeValues = [2.4, 1.6, 0.9, 0.2, 1.3, 1.9, 0.7, 1.1, 0.5, 1.8, 1.0, 0.4]
        let batteryDischargeValues = [0.9, 0.2, 1.3, 1.5, 0.7, 0.8, 1.6, 0.3, 0.6, 1.9, 0.4, 1.2]

        return StatsWidgetGraphView(
            home: [0.0, 0.5, 0.9, 1.2, 1.5, 1.8, 1.3, 0.7, 0.3, 1.0, 1.6, 0.2],
            gridImport: [2.0, 1.9, 1.8, 0.3, 0.5, 0.7, 1.0, 1.2, 1.7, 0.8, 1.5, 0.6],
            gridExport: [1.0, 1.2, 1.8, 0.4, 0.9, 0.7, 1.3, 1.5, 0.2, 1.1, 1.9, 0.6],
            batteryCharge: [2.4, 1.6, 0.9, 0.2, 1.3, 1.9, 0.7, 1.1, 0.5, 1.8, 1.0, 0.4],
            batteryDischarge: [0.9, 0.2, 1.3, 1.5, 0.7, 0.8, 1.6, 0.3, 0.6, 1.9, 0.4, 1.2],
            totalHome: homeValues.reduce(0, +),
            totalGridImport: gridImportValues.reduce(0, +),
            totalGridExport: gridExportValues.reduce(0, +),
            totalBatteryCharge: batteryChargeValues.reduce(0, +),
            totalBatteryDischarge: batteryDischargeValues.reduce(0, +),
            lastUpdated: .now
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}
