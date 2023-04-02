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
        Chart(viewModel.data, id: \.variable.title) {
            AreaMark(
                x: .value("hour", $0.date),
                y: .value("kW", $0.value),
                series: .value("Title", $0.variable.title),
                stacking: .unstacked
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
                        Text(amount.kW(2))
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

struct UsageGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let model = GraphTabViewModel(DemoNetworking(), configManager: MockConfigManager())
        return UsageGraphView(
            viewModel: model,
            selectedDate: .constant(nil),
            valuesAtTime: .constant(nil)
        )
    }
}
