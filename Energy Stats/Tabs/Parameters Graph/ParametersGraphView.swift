//
//  ParametersGraphView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/11/2022.
//

import Charts
import Energy_Stats_Core
import SwiftUI

struct ParametersGraphView: View {
    private let unit: String?
    @Binding var selectedDate: Date?
    @Binding var valuesAtTime: ValuesAtTime<ParameterGraphValue>?
    private let data: ParametersGraphViewData
    @State private var captionBoxSize: CGSize = .zero
    private let truncateYAxis: Bool
    private let haptic = UIImpactFeedbackGenerator()

    init(
        unit: String?,
        selectedDate: Binding<Date?>,
        valuesAtTime: Binding<ValuesAtTime<ParameterGraphValue>?>,
        truncateYAxis: Bool,
        data: ParametersGraphViewData
    ) {
        self.unit = unit
        self._selectedDate = selectedDate
        self._valuesAtTime = valuesAtTime
        self.truncateYAxis = truncateYAxis
        self.data = data
    }

    var body: some View {
        ParametersGraphChartView(values: self.data.values, xScale: data.xScale, truncateYAxis: truncateYAxis, stride: data.stride, unit: unit)
            .chartOverlay { chartProxy in
                GeometryReader { geometryProxy in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 20)
                            .onChanged { currentState in
                                guard let plotFrame = chartProxy.plotFrame else { return }
                                let xLocation = currentState.location.x - geometryProxy[plotFrame].origin.x

                                if let plotElement = chartProxy.value(atX: xLocation, as: Date.self) {
                                    if let graphValue = data.values.first(where: {
                                        $0.date > plotElement
                                    }), selectedDate != graphValue.date {
                                        selectedDate = graphValue.date
                                        valuesAtTime = data(at: graphValue.date)
                                    }
                                }
                            }
                        )
                        .gesture(SpatialTapGesture()
                            .onEnded { value in
                                guard let plotFrame = chartProxy.plotFrame else { return }
                                let xLocation = value.location.x - geometryProxy[plotFrame].origin.x

                                if let plotElement = chartProxy.value(atX: xLocation, as: Date.self) {
                                    if let graphValue = data.values.first(where: {
                                        $0.date > plotElement
                                    }) {
                                        selectedDate = graphValue.date
                                        valuesAtTime = data(at: graphValue.date)
                                    }
                                }
                            }
                        )
                }
            }
            .chartOverlay { makeHighlightBar(chartProxy: $0) }
            .chartOverlay { makeCaptionBox(chartProxy: $0) }
            .onAppear { haptic.prepare() }
    }

    private func data(at date: Date) -> ValuesAtTime<ParameterGraphValue> {
        let result = ValuesAtTime(values: data.visibleRawData.filter { $0.date == date })

        if let maxDate = data.max?.date, date == maxDate {
            haptic.impactOccurred()
        }

        return result
    }

    private func makeCaptionBox(chartProxy: ChartProxy) -> some View {
        GeometryReader { geometryReader in
            if let date = selectedDate,
               let plotFrame = chartProxy.plotFrame,
               let elementLocation = chartProxy.position(forX: date)
            {
                let location = elementLocation - geometryReader[plotFrame].origin.x
                let furthestRight = geometryReader[plotFrame].width - captionBoxSize.width

                if let valuesAtTime {
                    let graphValuesAtTime: [ParameterGraphValue] = valuesAtTime.values.filter { $0.type.unit == unit }

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
                    .background(Color.background.opacity(0.6))
                    .border(Color.gray)
                    .offset(x: min(location, furthestRight))
                    .readSize(into: $captionBoxSize)
                }
            }
        }
    }

    private func makeHighlightBar(chartProxy: ChartProxy) -> some View {
        GeometryReader { geometryReader in
            if let date = selectedDate,
               let plotFrame = chartProxy.plotFrame,
               let elementLocation = chartProxy.position(forX: date)
            {
                let location = elementLocation - geometryReader[plotFrame].origin.x

                Rectangle()
                    .fill(Color("graph_highlight"))
                    .frame(width: 1, height: chartProxy.plotSize.height)
                    .offset(x: location)
            }
        }
    }
}

struct UsageGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let model = ParametersGraphTabViewModel(
            networking: NetworkService.preview(),
            configManager: ConfigManager.preview(),
            solarForecastProvider: { PreviewSolcast() }
        )
        Task { await model.load() }
        return ParametersGraphView(
            unit: "℃",
            selectedDate: .constant(nil),
            valuesAtTime: .constant(nil),
            truncateYAxis: false,
            data: ParametersGraphViewData(
                visibleRawData: [],
                values: [],
                yScale: 1 ... 10,
                xScale: model.xScale,
                stride: model.stride,
                max: nil
            )
        )
    }
}
