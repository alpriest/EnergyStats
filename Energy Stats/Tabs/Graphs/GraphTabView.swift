//
//  GraphTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Charts
import SwiftUI

struct GraphTabView: View {
    @ObservedObject var viewModel: GraphTabViewModel
    @State private var selectedDate: Date?
    @GestureState var isDetectingPress = true
    @State private var valuesAtTime: ValuesAtTime?

    var body: some View {
        VStack {
            Picker("Hours", selection: $viewModel.hours) {
                Text("6").tag(6)
                Text("12").tag(12)
                Text("24").tag(24)
            }.pickerStyle(.segmented)

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
                content.background(Color.gray.gradient.opacity(0.2))
            }
            .chartXAxis(content: {
                AxisMarks(values: .stride(by: .hour)) { value in
                    if value.index % 2 == 0, let date = value.as(Date.self) {
                        AxisValueLabel(centered: true) {
                            Text(date.formatted(.dateTime.hour()))
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
            .chartOverlay { chartProxy in
                GeometryReader { geometryProxy in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(DragGesture()
                            .updating($isDetectingPress) { currentState, _, _ in
                                let xLocation = currentState.location.x - geometryProxy[chartProxy.plotAreaFrame].origin.x

                                if let plotElement: Date = chartProxy.value(atX: xLocation) {
                                    if let day = viewModel.data.sorted(by: { lhs, rhs in
                                        lhs.date < rhs.date
                                    }).first(where: {
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
            .chartBackground { chartProxy in
                GeometryReader { geometryReader in
                    if let date = selectedDate,
                       let elementLocation = chartProxy.position(forX: date),
                       let location = elementLocation - geometryReader[chartProxy.plotAreaFrame].origin.x
                    {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.yellow)
                            .frame(width: 2, height: chartProxy.plotAreaSize.height)
                            .offset(x: location)
                    }
                }
            }

            Color.clear.overlay(OptionalView(valuesAtTime) { valuesAtTime in
                VStack {
                    OptionalView(selectedDate) { Text($0.small()) }
                    ForEach(valuesAtTime.values, id: \.id) { graphValue in
                        HStack {
                            Text(graphValue.variable.title)
                            Text(graphValue.value.kW())
                        }
                    }
                }
            }).frame(height: 150)

            Spacer()

            VStack(alignment: .leading) {
                List(viewModel.variables, id: \.self) { variable in
                    HStack {
                        Button(action: { viewModel.toggle(visibilityOf: variable) }) {
                            HStack(alignment: .top) {
                                Circle()
                                    .foregroundColor(variable.type.colour)
                                    .frame(width: 15, height: 15)
                                    .padding(.top, 5)

                                VStack(alignment: .leading) {
                                    Text(variable.type.title)
                                    Text(variable.type.description)
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                                .opacity(variable.enabled ? 1.0 : 0.5)

                                Spacer()

                                OptionalView(viewModel.total(of: variable.type)) {
                                    Text($0.kW())
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowBackground(Color.white.opacity(0.5))
                    .listRowSeparator(.hidden)
                }
                .scrollDisabled(true)
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }.onChange(of: viewModel.variables) { _ in
                viewModel.refresh()
            }
        }
        .padding()
        .onAppear {
            viewModel.start()
        }
    }
}

struct GraphTabView_Previews: PreviewProvider {
    static var previews: some View {
        GraphTabView(viewModel: GraphTabViewModel(MockNetworking()))
    }
}
