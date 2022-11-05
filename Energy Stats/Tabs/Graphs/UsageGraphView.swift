//
//  UsageGraphView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/11/2022.
//

import Charts
import SwiftUI

struct UsageGraphView: View {
    @ObservedObject var viewModel: GraphTabViewModel
    @GestureState var isDetectingPress = true
    @Binding var selectedDate: Date?
    @Binding var valuesAtTime: ValuesAtTime?

    var body: some View {
        Chart(viewModel.data) {
            AreaMark(
                x: .value("Time", $0.date, unit: .minute),
                y: .value("kW", $0.value),
                series: .value("Title", $0.variable.title),
                stacking: .unstacked
            )
            .foregroundStyle($0.variable.colour)
        }
        .chartPlotStyle { content in
            content.background(Color.gray.gradient.opacity(0.1))
        }
        .chartXAxis(content: {
            AxisMarks(values: .stride(by: .hour)) { value in
                if value.index % viewModel.stride == 0, let date = value.as(Date.self) {
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
                        Text(amount.kW())
                    }
                }
            }
        })
        .chartYScale(domain: 0 ... 4)
        .chartOverlay { chartProxy in
            GeometryReader { geometryProxy in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(DragGesture()
                        .updating($isDetectingPress) { currentState, _, _ in
                            let xLocation = currentState.location.x - geometryProxy[chartProxy.plotAreaFrame].origin.x

                            if let plotElement = chartProxy.value(atX: xLocation, as: Date.self) {
                                if let day = viewModel.data.first(where: {
                                    $0.date > plotElement
                                }), selectedDate != plotElement {
                                    selectedDate = plotElement
                                    valuesAtTime = viewModel.data(at: day.date)
                                }
                            }
                        }
                    )
                    .gesture(SpatialTapGesture()
                        .onEnded { value in
                            let xLocation = value.location.x - geometryProxy[chartProxy.plotAreaFrame].origin.x

                            if let plotElement = chartProxy.value(atX: xLocation, as: Date.self) {
                                if let day = viewModel.data.first(where: {
                                    $0.date > plotElement
                                }) {
                                    selectedDate = plotElement
                                    valuesAtTime = viewModel.data(at: day.date)
                                }
                            }
                        }
                    )
            }
        }
        .chartOverlay { chartProxy in
            GeometryReader { geometryReader in
                if let date = selectedDate,
                   let elementLocation = chartProxy.position(forX: date),
                   let location = elementLocation - geometryReader[chartProxy.plotAreaFrame].origin.x
                {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 1, height: chartProxy.plotAreaSize.height)
                        .offset(x: location)
                }
            }
        }
    }
}

struct UsageGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let model = GraphTabViewModel(MockNetworking())
        return UsageGraphView(
            viewModel: model,
            selectedDate: .constant(nil),
            valuesAtTime: .constant(nil)
        )
    }
}
