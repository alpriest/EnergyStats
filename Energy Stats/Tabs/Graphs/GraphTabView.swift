//
//  GraphTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Charts
import SwiftUI
import Energy_Stats_Core

struct GraphTabView: View {
    @ObservedObject var viewModel: GraphTabViewModel
    @State private var valuesAtTime: ValuesAtTime?
    @State private var selectedDate: Date?

    var body: some View {
        VStack {
            OptionalView(viewModel.errorMessage) {
                Text($0)
            }

            Picker("Hours", selection: $viewModel.hours) {
                Text("6h").tag(6)
                Text("12h").tag(12)
                Text("24h").tag(24)
            }.pickerStyle(.segmented)

            UsageGraphView(viewModel: viewModel,
                           selectedDate: $selectedDate,
                           valuesAtTime: $valuesAtTime)

            Color.clear.overlay(OptionalView(valuesAtTime) { valuesAtTime in
                VStack {
                    OptionalView(selectedDate) {
                        Text($0.small())
                    }

                    ForEach(valuesAtTime.values, id: \.id) { graphValue in
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                            Text(graphValue.variable.title(as: .snapshot))
                            Text(graphValue.value.kW(2))
                                .monospacedDigit()
                        }
                    }
                }
            })
            .frame(height: 150)
            .font(.caption)

            VStack(alignment: .leading) {
                List(viewModel.graphVariables, id: \.self) { variable in
                    HStack {
                        Button(action: { viewModel.toggle(visibilityOf: variable) }) {
                            HStack(alignment: .top) {
                                Circle()
                                    .foregroundColor(variable.type.colour)
                                    .frame(width: 15, height: 15)
                                    .padding(.top, 5)

                                VStack(alignment: .leading) {
                                    Text(variable.type.title(as: .total))
                                    Text(variable.type.description)
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                OptionalView(viewModel.total(of: variable.type.reportVariable)) {
                                    Text($0.kWh(2))
                                }
                            }
                            .opacity(variable.enabled ? 1.0 : 0.5)
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowSeparator(.hidden)
                }
                .scrollDisabled(true)
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }.onChange(of: viewModel.graphVariables) { _ in
                viewModel.refresh()
            }
        }
        .padding()
        .task {
            await viewModel.start()
        }
    }
}

struct GraphTabView_Previews: PreviewProvider {
    static var previews: some View {
        GraphTabView(viewModel: GraphTabViewModel(DemoNetworking(), configManager: PreviewConfigManager()))
    }
}
