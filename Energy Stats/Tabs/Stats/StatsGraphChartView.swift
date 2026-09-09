//
//  StatsGraphChartView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/09/2026.
//

import Charts
import Energy_Stats_Core
import SwiftUI

struct StatsGraphChartView: View {
    let unit: Calendar.Component
    let showBatterySOCOnDailyStats: Bool
    let showInverterConsumption: Bool
    let statsTimeUsageGraphStyle: StatsTimeUsageGraphStyle
    let showSelfSufficiencyStatsGraphOverlay: Bool
    let selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode
    let normalData: [StatsGraphValue]
    let selfSufficiencyGraphData: [StatsGraphValue]
    let inverterConsumptionGraphData: [StatsGraphValue]
    let batterySOCGraphData: [StatsGraphValue]

    var body: some View {
        Chart {
            ForEach(normalData, id: \.type.titleTotal) { dataPoint in
                if statsTimeUsageGraphStyle.isLine {
                    LineMark(
                        x: .value("hour", dataPoint.date, unit: unit),
                        y: .value("Amount", dataPoint.graphValue),
                        series: .value("Series", dataPoint.type.networkTitle)
                    )
                    .foregroundStyle(dataPoint.type.colour)
                }

                if statsTimeUsageGraphStyle.isBar {
                    BarMark(
                        x: .value("hour", dataPoint.date, unit: unit),
                        y: .value("Amount", dataPoint.graphValue)
                    )
                    .position(by: .value("parameter", dataPoint.type.networkTitle))
                    .foregroundStyle(dataPoint.type.colour)
                }
            }

            if showSelfSufficiencyStatsGraphOverlay && selfSufficiencyEstimateMode != .off {
                ForEach(selfSufficiencyGraphData) {
                    LineMark(
                        x: .value("hour", $0.date, unit: unit),
                        y: .value("Amount", $0.graphValue),
                        series: .value("Self Sufficiency", "Self Sufficiency")
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [2, 4]))
                    .foregroundStyle(Color("background_inverted"))
                }
            }

            if showInverterConsumption {
                ForEach(inverterConsumptionGraphData) {
                    LineMark(
                        x: .value("hour", $0.date, unit: unit),
                        y: .value("Amount", $0.graphValue),
                        series: .value("Inverter Consumption", "Inverter Consumption")
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .foregroundStyle(Color.pink)
                }
            }

            if showBatterySOCOnDailyStats {
                ForEach(batterySOCGraphData) {
                    LineMark(
                        x: .value("hour", $0.date, unit: .hour),
                        y: .value("Amount", $0.graphValue),
                        series: .value("Battery SOC", "Battery SOC")
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .foregroundStyle(Color.cyan)
                }
            }
        }
    }
}
