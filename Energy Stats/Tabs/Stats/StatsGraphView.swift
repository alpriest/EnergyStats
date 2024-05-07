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
    var id: String { type.title }

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
    let value: Double
    let type: ReportVariable

    var id: String { "\(date.iso8601())_\(type.networkTitle)" }

    init(date: Date, value: Double, type: ReportVariable) {
        self.date = date
        self.value = value
        self.type = type
    }

    func formatted(_ decimalPlaces: Int) -> String {
        value.kWh(decimalPlaces)
    }
}

@available(iOS 16.0, *)
struct StatsGraphView: View {
    let viewModel: StatsTabViewModel
    @GestureState var isDetectingPress = true
    @Binding var selectedDate: Date?
    @State private var nextDate: Date?
    @Binding var valuesAtTime: ValuesAtTime<StatsGraphValue>?

    var body: some View {
        ZStack {
            Chart(viewModel.selfSufficiencyAtDateTime) {
                LineMark(
                    x: .value("hour", $0.date, unit: viewModel.unit),
                    y: .value("Amount", $0.value)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [2,4]))
                .foregroundStyle(Color.pink)
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(position: .bottom, values: .automatic) { _ in
                    AxisValueLabel {
                        Text("")
                    }
                }
            }
            .chartXScale(domain: viewModel.scale)

            Chart(viewModel.data, id: \.type.title) {
                BarMark(
                    x: .value("hour", $0.date, unit: viewModel.unit),
                    y: .value("Amount", $0.value)
                )
                .position(by: .value("parameter", $0.type.networkTitle))
                .foregroundStyle($0.type.colour)
            }
            .chartPlotStyle { content in
                content.background(Color.gray.gradient.opacity(0.04))
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: viewModel.unit, count: viewModel.stride)) { value in
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
                        .gesture(DragGesture()
                            .updating($isDetectingPress) { currentState, _, _ in
                                let xLocation = currentState.location.x - geometryProxy[chartProxy.plotAreaFrame].origin.x

                                if let plotElement = chartProxy.value(atX: xLocation, as: Date.self) {
                                    if let graphValue = viewModel.data.reversed().first(where: { plotElement > $0.date }),
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
                                   let graphValue = viewModel.data.reversed().first(where: { plotElement > $0.date })
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

                if let firstDate = viewModel.data[safe: 0]?.date, let secondDate = viewModel.data.first(where: { $0.date > firstDate })?.date,
                   let firstPosition = chartProxy.position(forX: firstDate), let secondPosition = chartProxy.position(forX: secondDate)
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
@available(iOS 16.0, *)
#Preview {
    VStack {
        Text(verbatim: "Day by hours")
        let viewModel = StatsTabViewModel(networking: DemoNetworking(), configManager: PreviewConfigManager())

        StatsGraphView(
            viewModel: viewModel,
            selectedDate: .constant(nil),
            valuesAtTime: .constant(nil)
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
