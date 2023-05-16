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
    typealias Data = [StatsGraphValue]
    let data: Data
    let unit: Calendar.Component
    let stride: Int

    var body: some View {
        Chart(data, id: \.type.title) {
            BarMark(
                x: .value("hour", $0.date, unit: unit),
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
            AxisMarks(values: .stride(by: unit, count: stride)) { value in
                if let date = value.as(Date.self) {
                    AxisTick(centered: true)
                    AxisValueLabel(centered: false) {
                        switch unit {
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
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct StatsGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let variables = [ReportVariable(rawValue: "feedin")!, ReportVariable(rawValue: "generation")!, ReportVariable(rawValue: "gridConsumption")!, ReportVariable(rawValue: "chargeEnergyToTal")!, ReportVariable(rawValue: "dischargeEnergyToTal")!]

        ScrollView {
            VStack {
                Text("Day by hours")
                let hourlyData = variables.flatMap { v in
                    (1 ... 12).map { h in
                        StatsGraphValue(date: .hoursAgo(h), value: Double(h), type: v)
                    }
                }
                StatsGraphView(data: hourlyData, unit: .hour, stride: 3)

                Text("Month by days")
                let monthlyData = variables.flatMap { v in
                    (1 ... 31).map { h in
                        StatsGraphValue(date: .dayOfMonth(h), value: Double(h), type: v)
                    }
                }
                StatsGraphView(data: monthlyData, unit: .day, stride: 3)

                Text("Year by months")
                let yearData = variables.flatMap { v in
                    (1 ... 12).map { h in
                        StatsGraphValue(date: .month(h), value: Double(h), type: v)
                    }
                }
                StatsGraphView(data: yearData, unit: .month, stride: 3)
            }
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
