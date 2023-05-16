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
                    .padding(.horizontal)

                ScrollView {
                    ParametersGraphView(viewModel: viewModel,
                                   selectedDate: $selectedDate,
                                   valuesAtTime: $valuesAtTime)
                        .frame(height: 250)
                        .padding(.vertical)

                    GraphVariablesToggles(viewModel: viewModel, selectedDate: $selectedDate, valuesAtTime: $valuesAtTime)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingVariables) {
            GraphVariableChooserView(viewModel: GraphVariableChooserViewModel(variables: viewModel.graphVariables, onApply: { viewModel.set(graphVariables: $0) }))
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
