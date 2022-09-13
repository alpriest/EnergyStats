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
    let credentials: Credentials
    @State private var selectedDate: Date?
    @GestureState var isDetectingPress = true
    @State private var valuesAtTime: ValuesAtTime?

    var body: some View {
        VStack {
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
                            .onEnded { _ in
                                valuesAtTime = nil
                                selectedDate = nil
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
                    ForEach(valuesAtTime.values, id: \.id) { graphValue in
                        HStack {
                            Text(graphValue.variable.title)
                            Text(graphValue.value.kW())
                        }
                    }
                }
            }).frame(height: 150)

            VStack(alignment: .leading) {
                List(viewModel.variables.indices, id: \.self) { index in
                    HStack {
                        Toggle(isOn: $viewModel.variables[index].enabled) {
                            HStack {
                                Circle()
                                    .foregroundColor(viewModel.variables[index].type.colour)
                                    .frame(width: 15, height: 15)

                                OptionalView(viewModel.total(of: viewModel.variables[index].type)) {
                                    Text($0.kW())
                                }

                                VStack(alignment: .leading) {
                                    Text(viewModel.variables[index].type.title)
                                    Text(viewModel.variables[index].type.description)
                                        .font(.system(size: 8))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .scrollDisabled(true)
                .listStyle(.plain)
            }.onChange(of: viewModel.variables) { _ in
                viewModel.refresh()
            }
            .font(.caption)

            Button("logout") {
                credentials.username = nil
                credentials.password = nil
                credentials.hasCredentials = false
            }.buttonStyle(.bordered)
        }
        .padding()
        .onAppear {
            viewModel.start()
        }
    }
}

struct GraphTabView_Previews: PreviewProvider {
    static var previews: some View {
        GraphTabView(viewModel: GraphTabViewModel(MockNetworking()), credentials: Credentials())
    }
}
