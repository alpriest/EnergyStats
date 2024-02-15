//
//  ParametersGraphView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/11/2022.
//

import Charts
import Energy_Stats_Core
import SwiftUI

@available(iOS 16.0, *)
struct ParametersGraphView: View {
    private let key: String?
    @ObservedObject var viewModel: ParametersGraphTabViewModel
    @GestureState var isDetectingPress = true
    @Binding var selectedDate: Date?
    @Binding var valuesAtTime: ValuesAtTime<ParameterGraphValue>?
    private let data: [ParameterGraphValue]
    @State private var captionBoxSize: CGSize = .zero

    init(key: String?, viewModel: ParametersGraphTabViewModel, selectedDate: Binding<Date?>, valuesAtTime: Binding<ValuesAtTime<ParameterGraphValue>?>) {
        self.key = key
        self.viewModel = viewModel
        self._selectedDate = selectedDate
        self._valuesAtTime = valuesAtTime

        if let key {
            self.data = viewModel.data[key] ?? []
        } else {
            self.data = viewModel.data.values.flatMap { $0 }
        }
    }

    var body: some View {
        Chart(data, id: \.type.variable) {
            LineMark(
                x: .value("hour", $0.date),
                y: .value("", $0.value),
                series: .value("Title", $0.type.title(as: .snapshot))
            )
            .foregroundStyle($0.type.colour)
        }
        .chartPlotStyle { content in
            content.background(Color.gray.gradient.opacity(0.04))
        }
        .chartXScale(domain: viewModel.xScale)
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: viewModel.stride)) { value in
                if let date = value.as(Date.self) {
                    AxisTick(centered: false)
                    AxisValueLabel(centered: false) {
                        Text(date, format: .dateTime.hour())
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                if let amount = value.as(Double.self) {
                    AxisGridLine()
                    AxisValueLabel {
                        if let key {
                            Text("\(amount, format: .number) \(key)")
                        } else {
                            Text("\(amount, format: .number)")
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
                                if let graphValue = data.first(where: {
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
                                if let graphValue = data.first(where: {
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
        .chartOverlay { makeHighlightBar(chartProxy: $0) }
        .chartOverlay { makeCaptionBox(chartProxy: $0) }
    }

    private func makeCaptionBox(chartProxy: ChartProxy) -> some View {
        GeometryReader { geometryReader in
            if let date = selectedDate,
               let elementLocation = chartProxy.position(forX: date)
            {
                let location = elementLocation - geometryReader[chartProxy.plotAreaFrame].origin.x
                let furthestRight = geometryReader[chartProxy.plotAreaFrame].width - captionBoxSize.width

                if let valuesAtTime {
                    let graphValuesAtTime: [ParameterGraphValue] = valuesAtTime.values.filter { $0.type.unit == key }

                    HStack {
                        VStack(alignment: .leading) {
                            ForEach(graphValuesAtTime, id: \.self) { value in
                                Text(value.type.name)
                            }
                        }

                        VStack(alignment: .trailing) {
                            ForEach(graphValuesAtTime, id: \.self) { value in
                                Text(value.formatted())
                                    .monospacedDigit()
                            }
                        }
                    }
                    .padding(4)
                    .font(.caption)
                    .background(Color.white)
                    .border(Color.gray)
                    .offset(x: min(location, furthestRight))
                    .background(GeometryReader { reader in
                        Color.clear.onAppear { captionBoxSize = reader.size }.onChange(of: reader.size) { newValue in captionBoxSize = newValue }
                    })
                }
            }
        }
    }

    private func makeHighlightBar(chartProxy: ChartProxy) -> some View {
        GeometryReader { geometryReader in
            if let date = selectedDate,
               let elementLocation = chartProxy.position(forX: date)
            {
                let location = elementLocation - geometryReader[chartProxy.plotAreaFrame].origin.x

                Rectangle()
                    .fill(Color("graph_highlight"))
                    .frame(width: 1, height: chartProxy.plotAreaSize.height)
                    .offset(x: location)
            }
        }
    }
}

@available(iOS 16.0, *)
struct UsageGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let model = ParametersGraphTabViewModel(networking: DemoNetworking(), configManager: PreviewConfigManager())
        Task { await model.load() }
        return ParametersGraphView(
            key: "℃",
            viewModel: model,
            selectedDate: .constant(nil),
            valuesAtTime: .constant(nil)
        )
    }
}
