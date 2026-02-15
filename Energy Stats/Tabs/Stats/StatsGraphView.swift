//
//  StatsGraphView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import Charts
import Energy_Stats_Core
import SwiftUI

struct StatsGraphVariable: Identifiable, Equatable, Hashable {
    let type: ReportVariable
    var enabled: Bool
    var id: String { type.titleTotal }

    init(_ type: ReportVariable, enabled: Bool = true) {
        self.type = type
        self.enabled = enabled
    }

    init?(_ type: ReportVariable?, enabled: Bool = true) {
        guard let type else { return nil }

        self.init(type, enabled: enabled)
    }
}

struct StatsGraphValue: Identifiable, Hashable {
    let date: Date
    let graphValue: Double
    let type: ReportVariable
    let displayValue: Double?

    var id: String { "\(date.iso8601())_\(type.networkTitle)" }

    init(type: ReportVariable, date: Date, graphValue: Double, displayValue: Double?) {
        self.type = type
        self.date = date
        self.graphValue = graphValue
        self.displayValue = displayValue
    }

    func formatted(_ decimalPlaces: Int) -> String {
        switch type {
        case .selfSufficiency, .batterySOC:
            (displayValue ?? graphValue).percent()
        default:
            (displayValue ?? graphValue).kWh(decimalPlaces)
        }
    }

    var isForNormalGraph: Bool {
        type != .selfSufficiency && type != .inverterConsumption && type != .batterySOC
    }

    var isForSelfSufficiencyGraph: Bool {
        type == .selfSufficiency
    }

    var isForInverterConsumptionGraph: Bool {
        type == .inverterConsumption
    }

    var isForBatterySOCGraph: Bool {
        type == .batterySOC
    }
}

struct StatsGraphView: View {
    let viewModel: StatsTabViewModel
    @GestureState var isDetectingPress = true
    @Binding var selectedDate: Date?
    @State private var nextDate: Date?
    @Binding var valuesAtTime: ValuesAtTime<StatsGraphValue>?
    let appSettings: AppSettings

    var body: some View {
        ZStack {
            Chart {
                ForEach(viewModel.data.filter { $0.isForNormalGraph }, id: \.type.titleTotal) {
                    LineMark(
                        x: .value("hour", $0.date, unit: viewModel.unit),
                        y: .value("Amount", $0.graphValue),
                        series: .value("Series", $0.type.networkTitle)
                    )
                    .foregroundStyle($0.type.colour)
                }

                if appSettings.showSelfSufficiencyStatsGraphOverlay && appSettings.selfSufficiencyEstimateMode != .off {
                    ForEach(viewModel.data.filter { $0.isForSelfSufficiencyGraph }) {
                        LineMark(
                            x: .value("hour", $0.date, unit: viewModel.unit),
                            y: .value("Amount", $0.graphValue),
                            series: .value("Self Sufficiency", "Self Sufficiency")
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [2, 4]))
                        .foregroundStyle(Color("background_inverted"))
                    }
                }

                if appSettings.showInverterConsumption {
                    ForEach(viewModel.data.filter { $0.isForInverterConsumptionGraph }) {
                        LineMark(
                            x: .value("hour", $0.date, unit: viewModel.unit),
                            y: .value("Amount", $0.graphValue),
                            series: .value("Inverter Consumption", "Inverter Consumption")
                        )
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .foregroundStyle(Color.pink)
                    }
                }

                if appSettings.showBatterySOCOnDailyStats {
                    ForEach(viewModel.data.filter { $0.isForBatterySOCGraph }) {
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
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 20)
                            .updating($isDetectingPress) { currentState, _, _ in
                                let xLocation = currentState.location.x - geometryProxy[chartProxy.plotAreaFrame].origin.x

                                if let plotElement = chartProxy.value(atX: xLocation, as: Date.self) {
                                    if let graphValue = viewModel.data.filter({ $0.isForNormalGraph }).reversed().first(where: { plotElement > $0.date }),
                                       selectedDate != graphValue.date
                                    {
                                        Task { @MainActor in
                                            selectedDate = graphValue.date
                                            valuesAtTime = viewModel.data(at: graphValue.date)
                                        }
                                    }
                                }
                            }
                        )
                        .gesture(SpatialTapGesture()
                            .onEnded { value in
                                let xLocation = value.location.x - geometryProxy[chartProxy.plotAreaFrame].origin.x

                                if let plotElement = chartProxy.value(atX: xLocation, as: Date.self),
                                   let graphValue = viewModel.data.filter({ $0.isForNormalGraph }).reversed().first(where: { plotElement > $0.date })
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
            .chartOverlay { makeHighlightBar(chartProxy: $0) }
        }
    }

    private func makeHighlightBar(chartProxy: ChartProxy) -> some View {
        GeometryReader { geometryReader in
            if let date = selectedDate,
               let elementLocation = chartProxy.position(forX: date)
            {
                let location = elementLocation - geometryReader[chartProxy.plotAreaFrame].origin.x
                let filteredData = viewModel.data.filter { $0.isForNormalGraph }

                if let firstDate = filteredData.first?.date,
                   let secondDate = filteredData.first(where: { $0.date > firstDate })?.date,
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
