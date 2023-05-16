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
    var isSelected: Bool
    var id: String { type.title }

    init(_ type: ReportVariable, isSelected: Bool = false, enabled: Bool = true) {
        self.type = type
        self.enabled = enabled
        self.isSelected = isSelected
    }

    init?(_ type: ReportVariable?, isSelected: Bool = false, enabled: Bool = true) {
        guard let type else { return nil }

        self.init(type, isSelected: isSelected, enabled: enabled)
    }

    mutating func setSelected(_ selected: Bool) {
        isSelected = selected
        enabled = true
    }
}

struct StatsGraphValue: Identifiable {
    let date: Date
    let value: Double
    let type: ReportVariable

    var id: String { "\(date.iso8601())_\(type.networkTitle)" }

    init(date: Date, value: Double, type: ReportVariable) {
        self.date = date
        self.value = value
        self.type = type
    }

    func formatted() -> String {
        value.kW(2)
    }
}

@available(iOS 16.0, *)
struct StatsGraphView: View {
    let viewModel: StatsTabViewModel
    @GestureState var isDetectingPress = true
    @Binding var selectedDate: Date?
    @Binding var valuesAtTime: ValuesAtTime<StatsGraphValue>?

    var body: some View {
        Chart(viewModel.data, id: \.type.title) {
            BarMark(
                x: .value("hour", $0.date, unit: viewModel.unit),
                y: .value("Amount", $0.value)
            )
            .position(by: .value("parameter", $0.type.networkTitle))
            .foregroundStyle($0.type.colour)
        }
        .chartPlotStyle { content in
            content.background(Color.gray.gradient.opacity(0.02))
        }
        .chartLegend(.hidden)
        .chartXAxis(content: {
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
        })
        .chartOverlay { chartProxy in
            GeometryReader { geometryProxy in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(DragGesture()
                        .updating($isDetectingPress) { currentState, _, _ in
                            let xLocation = currentState.location.x - geometryProxy[chartProxy.plotAreaFrame].origin.x

                            if let plotElement = chartProxy.value(atX: xLocation, as: Date.self) {
                                if let graphValue = viewModel.data.first(where: {
                                    $0.date > plotElement
                                }), selectedDate != graphValue.date {
                                    selectedDate = graphValue.date
                                    valuesAtTime = viewModel.data(at: graphValue.date)
                                }
                            }
                        }
                    )
                    .gesture(SpatialTapGesture()
                        .onEnded { value in
                            let xLocation = value.location.x - geometryProxy[chartProxy.plotAreaFrame].origin.x

                            if let plotElement = chartProxy.value(atX: xLocation, as: Date.self) {
                                if let graphValue = viewModel.data.first(where: {
                                    $0.date > plotElement
                                }) {
                                    selectedDate = graphValue.date
                                    valuesAtTime = viewModel.data(at: graphValue.date)
                                }
                            }
                        }
                    )
            }
        }
        .chartOverlay { chartProxy in
            GeometryReader { geometryReader in
                if let date = selectedDate,
                   let elementLocation = chartProxy.position(forX: date)
                {
                    let location = elementLocation - geometryReader[chartProxy.plotAreaFrame].origin.x

                    Rectangle()
                        .fill(Color("lines_notflowing"))
                        .frame(width: 1, height: chartProxy.plotAreaSize.height)
                        .offset(x: location)
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct StatsGraphView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Day by hours")
            StatsGraphView(
                viewModel: StatsTabViewModel(networking: DemoNetworking(), configManager: PreviewConfigManager()),
                selectedDate: .constant(nil),
                valuesAtTime: .constant(nil)
            )
        }
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
