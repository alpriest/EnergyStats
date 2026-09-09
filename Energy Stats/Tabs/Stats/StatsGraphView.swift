//
//  StatsGraphView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import Charts
import Energy_Stats_Core
import SwiftUI

struct StatsGraphView: View {
    @ObservedObject var viewModel: StatsTabViewModel
    @Binding var selectedDate: Date?
    @Binding var valuesAtTime: ValuesAtTime<StatsGraphValue>?
    let appSettings: AppSettings
    @State private var normalData: [StatsGraphValue] = []
    @State private var selfSufficiencyGraphData: [StatsGraphValue] = []
    @State private var inverterConsumptionGraphData: [StatsGraphValue] = []
    @State private var batterySOCGraphData: [StatsGraphValue] = []

    var body: some View {
        ZStack {
            StatsGraphChartView(
                unit: viewModel.unit,
                showBatterySOCOnDailyStats: appSettings.showBatterySOCOnDailyStats,
                showInverterConsumption: appSettings.showInverterConsumption,
                statsTimeUsageGraphStyle: viewModel.statsTimeUsageGraphStyle,
                showSelfSufficiencyStatsGraphOverlay: appSettings.showSelfSufficiencyStatsGraphOverlay,
                selfSufficiencyEstimateMode: appSettings.selfSufficiencyEstimateMode,
                normalData: normalData,
                selfSufficiencyGraphData: selfSufficiencyGraphData,
                inverterConsumptionGraphData: inverterConsumptionGraphData,
                batterySOCGraphData: batterySOCGraphData
            )
            .chartXScale(domain: viewModel.xScale)
            .chartYScale(domain: viewModel.yScale)
            .chartPlotStyle { content in
                content.background(Color.gray.gradient.opacity(0.04))
            }
            .chartYAxis {
                AxisMarks { value in
                    if let value = value.as(Int.self) {
                        AxisGridLine()
                        AxisValueLabel(multiLabelAlignment: .trailing) {
                            Text(value, format: .number)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: viewModel.unit, count: 3)) { value in
                    if let date = value.as(Date.self) {
                        AxisTick(centered: true)
                        AxisValueLabel(centered: false) {
                            switch viewModel.unit {
                            case .month:
                                Text(date, format: .dateTime.month())
                            case .day:
                                Text(date, format: .dateTime.day())
                            case .hour:
                                Text(date, format: .dateTime.hour())
                            default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
            .chartOverlay { chartProxy in
                GeometryReader { geometryProxy in
                    if let plotFrame = chartProxy.plotFrame {
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 20)
                                    .onChanged { currentState in
                                        let xLocation =
                                            currentState.location.x - geometryProxy[plotFrame].origin.x

                                        guard
                                            let plotElement = chartProxy.value(atX: xLocation, as: Date.self),
                                            let graphValue = normalData
                                            .last(where: { plotElement > $0.date }),
                                            selectedDate != graphValue.date
                                        else {
                                            return
                                        }

                                        selectedDate = graphValue.date
                                        valuesAtTime = viewModel.data(at: graphValue.date)
                                    }
                            )
                            .gesture(SpatialTapGesture()
                                .onEnded { value in
                                    let xLocation = value.location.x - geometryProxy[plotFrame].origin.x

                                    if let plotElement = chartProxy.value(atX: xLocation, as: Date.self),
                                       let graphValue = normalData.reversed().first(where: { plotElement > $0.date })
                                    {
                                        Task { @MainActor in
                                            selectedDate = graphValue.date
                                            valuesAtTime = viewModel.data(at: selectedDate)
                                        }
                                    }
                                }
                            )
                    }
                }
            }
            .chartOverlay { makeHighlightBar(chartProxy: $0) }
            .onChange(of: viewModel.data, initial: true) {
                normalData = viewModel.data.filter { $0.isForNormalGraph }
                selfSufficiencyGraphData = viewModel.data.filter { $0.isForSelfSufficiencyGraph }
                inverterConsumptionGraphData = viewModel.data.filter { $0.isForInverterConsumptionGraph }
                batterySOCGraphData = viewModel.data.filter { $0.isForBatterySOCGraph }
            }
        }
    }

    private func makeHighlightBar(chartProxy: ChartProxy) -> some View {
        GeometryReader { geometryReader in
            if let plotFrame = chartProxy.plotFrame,
               let date = selectedDate,
               let elementLocation = chartProxy.position(forX: date)
            {
                let location = elementLocation - geometryReader[plotFrame].origin.x

                if let firstDate = normalData.first?.date,
                   let secondDate = normalData.first(where: { $0.date > firstDate })?.date,
                   let firstPosition = chartProxy.position(forX: firstDate),
                   let secondPosition = chartProxy.position(forX: secondDate)
                {
                    Rectangle()
                        .fill(Color("graph_highlight"))
                        .frame(width: secondPosition - firstPosition, height: chartProxy.plotAreaSize.height)
                        .offset(x: location)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        Text(verbatim: "Day by hours")
        let viewModel = StatsTabViewModel(
            networking: NetworkService.preview(),
            configManager: ConfigManager.preview()
        )

        StatsGraphView(
            viewModel: viewModel,
            selectedDate: .constant(nil),
            valuesAtTime: .constant(nil),
            appSettings: AppSettings.mock()
        ).onAppear { Task { await viewModel.load() } }
    }
}

extension Date {
    static func hoursAgo(_ hours: Int) -> Date {
        .now.addingTimeInterval(-3600 * Double(hours))
    }

    static func dayOfMonth(_ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: day))!
    }

    static func month(_ month: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2023, month: month, day: 1))!
    }
}
#endif
