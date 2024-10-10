//
//  StatsGraphView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/10/2024.
//

import Charts
import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct StatsGraphView: View {
    let gridImport: Double?
    let gridExport: Double?
    let home: Double?
    let batteryCharge: Double?
    let batteryDischarge: Double?
    let lastUpdated: Date

    var body: some View {
        Grid(alignment: .leading) {
            labelledAmount("Home", amount: home)
            labelledAmount("Grid In", amount: gridImport)
            labelledAmount("Grid Out", amount: gridExport)
            labelledAmount("Battery Charge", amount: batteryCharge)
            labelledAmount("Battery Discharge", amount: batteryDischarge)
        }.font(.caption)
    }

    private func labelledAmount(_ label: String, amount: Double?) -> some View {
        OptionalView(amount) { value in
            GridRow {
                Text(label)
                Text(value.kWh(2))
                    .monospacedDigit()

                Chart(Array([0, 0, 1, 1.5, 2, 2.5, 1.0, 0.0, 2.0, 0.0].enumerated()), id: \.offset) {
                    LineMark(
                        x: .value("hour", $0.0),
                        y: .value("kWh", $0.1)
                    )
                }
                .chartLegend(.hidden)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 14)
            }
            .padding(.bottom, 2)
        }
    }
}

struct StatsGraphView_Previews: PreviewProvider {
    static var mylightGray: Color { Color("pale_gray", bundle: Bundle(for: CountdownTimer.self)) }

    static var previews: some View {
        StatsGraphView(gridImport: 1.0, gridExport: 2.0, home: 3.0, batteryCharge: 4.0, batteryDischarge: 5.0, lastUpdated: .now)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .containerBackground(for: .widget) {
                Color.clear
            }
    }
}
