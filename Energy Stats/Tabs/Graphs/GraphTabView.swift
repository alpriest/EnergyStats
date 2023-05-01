//
//  GraphTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Charts
import Energy_Stats_Core
import SwiftUI

@available(iOS 16.0, *)
struct GraphTabView: View {
    @ObservedObject var viewModel: GraphTabViewModel
    @State private var valuesAtTime: ValuesAtTime?
    @State private var selectedDate: Date?
    @State private var showingVariables: Bool = false

    var body: some View {
        Group {
            VStack {
                GraphHeaderView(displayMode: $viewModel.displayMode, showingVariables: $showingVariables)

                ScrollView {
                    UsageGraphView(viewModel: viewModel,
                                   selectedDate: $selectedDate,
                                   valuesAtTime: $valuesAtTime)
                    .frame(height: 250)

                    if let valuesAtTime, let selectedDate {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "xmark.circle.fill")
                                .frame(width: 30, height: 30)
                                .onTapGesture { self.valuesAtTime = nil }

                            VStack {
                                Text(selectedDate, format: .dateTime)

                                ForEach(valuesAtTime.values, id: \.id) { graphValue in
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                                        Text(graphValue.variable.title(as: .snapshot))
                                        Text(graphValue.value.kW(2))
                                            .monospacedDigit()
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                        .background(Color.brown.opacity(0.05))
                        .font(.caption)
                    } else {
                        Color.clear.padding(.bottom, 44)
                    }

                    VStack(alignment: .leading) {
                        ForEach(viewModel.graphVariables, id: \.self) { variable in
                            if variable.isSelected {
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
                        }
                        .scrollDisabled(true)
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)

                    }.onChange(of: viewModel.graphVariables) { _ in
                        viewModel.refresh()
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingVariables) {
            GraphVariableChooserView(variables: $viewModel.graphVariables)
        }
        .task {
            Task {
                await viewModel.load()
            }
        }
    }
}

@available(iOS 16.0, *)
struct GraphTabView_Previews: PreviewProvider {
    static var previews: some View {
        GraphTabView(viewModel: GraphTabViewModel(DemoNetworking(), configManager: PreviewConfigManager()))
            .previewDevice("iPhone 13 Mini")
    }
}
