//
//  UsageGraphView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/11/2022.
//

import Charts
import Energy_Stats_Core
import SwiftUI

@available(iOS 16.0, *)
struct UsageGraphView<T: Graphable>: View {
    @ObservedObject var viewModel: T
    @GestureState var isDetectingPress = true
    @Binding var selectedDate: Date?
    @Binding var valuesAtTime: ValuesAtTime?

    var body: some View {
        Chart(viewModel.data, id: \.variable.variable) {
            LineMark(
                x: .value("hour", $0.date),
                y: .value("", $0.value),
                series: .value("Title", $0.variable.name) //TODO: (as: .snapshot))
            )
            .foregroundStyle($0.variable.colour)
        }
        .chartPlotStyle { content in
            content.background(Color.gray.gradient.opacity(0.02))
        }
        .chartXAxis(content: {
            AxisMarks(values: .stride(by: .hour)) { value in
                if (value.index == 0) || (value.index % viewModel.stride == 0), let date = value.as(Date.self) {
                    AxisTick(centered: false)
                    AxisValueLabel(centered: false) {
                        Text(date.militaryTime())
                    }
                }
            }
        })
        .chartYAxis(content: {
            AxisMarks { value in
                if let amount = value.as(Double.self) {
                    AxisValueLabel {
                        Text(amount, format: .number)
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

@available(iOS 16.0, *)
struct UsageGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let model = GraphTabViewModel(DemoNetworking(), configManager: PreviewConfigManager())
        Task { await model.load() }
        return UsageGraphView(
            viewModel: model,
            selectedDate: .constant(nil),
            valuesAtTime: .constant(nil)
        )
    }
}
