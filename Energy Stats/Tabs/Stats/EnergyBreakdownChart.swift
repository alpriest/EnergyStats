//
//  EnergyBreakdownChart.swift
//  Energy Stats
//
//  Created by Alistair Priest on 31/01/2026.
//

import Charts
import Energy_Stats_Core
import SwiftUI

struct EnergyBreakdownChartData {
    let gridImport: Double
    let pvGeneration: Double
    let gridExport: Double
    let homeConsumption: Double
    let batteryCharge: Double
    let batteryDischarge: Double

    init(viewModel: StatsTabViewModel) {
        if let valuesAtTime = viewModel.valuesAtTime {
            self.init(
                gridImport: valuesAtTime.values.filter { $0.type == .gridConsumption }.map { $0.graphValue }.reduce(0, +),
                pvGeneration: valuesAtTime.values.filter { $0.type == .pvEnergyTotal }.map { $0.graphValue }.reduce(0, +),
                gridExport: valuesAtTime.values.filter { $0.type == .feedIn }.map { $0.graphValue }.reduce(0, +),
                homeConsumption: valuesAtTime.values.filter { $0.type == .loads }.map { $0.graphValue }.reduce(0, +),
                batteryCharge: valuesAtTime.values.filter { $0.type == .chargeEnergyToTal }.map { $0.graphValue }.reduce(0, +),
                batteryDischarge: valuesAtTime.values.filter { $0.type == .dischargeEnergyToTal }.map { $0.graphValue }.reduce(0, +)
            )
        } else {
            self.init(
                gridImport: viewModel.total(of: .gridConsumption) ?? 0,
                pvGeneration: viewModel.total(of: .pvEnergyTotal) ?? 0,
                gridExport: viewModel.total(of: .feedIn) ?? 0,
                homeConsumption: viewModel.total(of: .loads) ?? 0,
                batteryCharge: viewModel.total(of: .chargeEnergyToTal) ?? 0,
                batteryDischarge: viewModel.total(of: .dischargeEnergyToTal) ?? 0
            )
        }
    }

    internal init(gridImport: Double,
                  pvGeneration: Double,
                  gridExport: Double,
                  homeConsumption: Double,
                  batteryCharge: Double,
                  batteryDischarge: Double)
    {
        self.gridImport = gridImport
        self.pvGeneration = pvGeneration
        self.gridExport = gridExport
        self.homeConsumption = homeConsumption
        self.batteryCharge = batteryCharge
        self.batteryDischarge = batteryDischarge
    }
}

struct EnergyBreakdownChart: View {
    private let viewData: EnergyBreakdownChartData
    private let barData: [BarItem]
    private var range: ClosedRange<Double>

    init(_ viewData: EnergyBreakdownChartData) {
        self.viewData = viewData

        let barData = [
            BarItem(group: .inputs, variable: .dischargeEnergyToTal, value: viewData.batteryDischarge),
            BarItem(group: .inputs, variable: .gridConsumption, value: viewData.gridImport),
            BarItem(group: .inputs, variable: .pvEnergyTotal, value: viewData.pvGeneration),

            BarItem(group: .outputs, variable: .chargeEnergyToTal, value: viewData.batteryCharge),
            BarItem(group: .outputs, variable: .feedIn, value: viewData.gridExport),
            BarItem(group: .outputs, variable: .loads, value: viewData.homeConsumption)
        ].filter { $0.value > 0 }
        self.barData = barData

        self.range = {
            let min = 0.0
            let groupTotals = Group.allCases.map { group in
                barData.filter { $0.group == group }.map { $0.value }.reduce(0, +)
            }
            let max = groupTotals.max { a, b in
                a < b
            } ?? 0.0

            return min ... (max * 1.1)
        }()
    }

    private enum Group: String, CaseIterable, Identifiable {
        case inputs = "Energy Sources"
        case outputs = "Energy Uses"

        var id: String { rawValue }
        var title: String { rawValue }
    }

    private struct BarItem: Identifiable {
        let id = UUID()
        let group: Group
        let variable: ReportVariable
        let value: Double
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Chart(barData) { item in
                BarMark(
                    x: .value("Group", item.group.title),
                    y: .value("kWh", item.value)
                )
                .foregroundStyle(by: .value("Component", item.variable.title(usage: .omit)))
            }
            .chartForegroundStyleScale([
                ReportVariable.gridConsumption.title(usage: .omit): ReportVariable.gridConsumption.colour.gradient,
                ReportVariable.dischargeEnergyToTal.title(usage: .omit): ReportVariable.dischargeEnergyToTal.colour.gradient,
                ReportVariable.pvEnergyTotal.title(usage: .omit): ReportVariable.pvEnergyTotal.colour.gradient,
                ReportVariable.feedIn.title(usage: .omit): ReportVariable.feedIn.colour.gradient,
                ReportVariable.chargeEnergyToTal.title(usage: .omit): ReportVariable.chargeEnergyToTal.colour.gradient,
                ReportVariable.loads.title(usage: .omit): ReportVariable.loads.colour.gradient
            ])
            .chartYScale(domain: range)
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let title = value.as(String.self) {
                            Text(title + " " + total(for: title, from: barData))
                        }
                    }
                }
            }
            .chartLegend(.hidden)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func total(for group: Group, from barData: [BarItem]) -> String {
        let sum = barData.filter { $0.group == group }.map { $0.value }.reduce(0, +)
        return sum.kWh(1)
    }

    private func total(for groupTitle: String, from barData: [BarItem]) -> String {
        if let group = Group.allCases.first(where: { $0.title == groupTitle }) {
            return total(for: group, from: barData)
        } else {
            return ""
        }
    }

    private func label(for category: ReportVariable, value: Double) -> String {
        "\(value.kWh(1)) \(category.title(usage: .omit))"
    }
}

#if DEBUG
#Preview {
    EnergyBreakdownChart(
        EnergyBreakdownChartData(
            gridImport: 15.2,
            pvGeneration: 2.0,
            gridExport: 0.4,
            homeConsumption: 8.7,
            batteryCharge: 3.1,
            batteryDischarge: 4.6
        )
    )
    .padding()
}
#endif
