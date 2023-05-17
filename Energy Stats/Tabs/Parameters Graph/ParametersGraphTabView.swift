//
//  ParametersGraphTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Charts
import Energy_Stats_Core
import SwiftUI

@available(iOS 16.0, *)
struct ParametersGraphTabView: View {
    @StateObject var viewModel: ParametersGraphTabViewModel
    @State private var valuesAtTime: ValuesAtTime<GraphValue>?
    @State private var selectedDate: Date?
    @State private var showingVariables: Bool = false

    init(configManager: ConfigManaging, networking: Networking) {
        _viewModel = .init(wrappedValue: ParametersGraphTabViewModel(networking: networking, configManager: configManager))
    }

    var body: some View {
        Group {
            VStack {
                ParameterGraphHeaderView(displayMode: $viewModel.displayMode, showingVariables: $showingVariables)
                    .padding(.horizontal)

                ScrollView {
                    ParametersGraphView(viewModel: viewModel,
                                   selectedDate: $selectedDate,
                                   valuesAtTime: $valuesAtTime)
                        .frame(height: 250)
                        .padding(.vertical)

                    ParameterGraphVariablesToggles(viewModel: viewModel, selectedDate: $selectedDate, valuesAtTime: $valuesAtTime)

                    Text("Parameters are updated every 5 minutes by Fox and only available for a single day at a time")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.top, 44)
                        .foregroundColor(Color("text_dimmed"))
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingVariables) {
            ParameterGraphVariableChooserView(viewModel: ParameterGraphVariableChooserViewModel(variables: viewModel.graphVariables, onApply: { viewModel.set(graphVariables: $0) }))
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
        ParametersGraphTabView(configManager: PreviewConfigManager(), networking: DemoNetworking())
            .previewDevice("iPhone 13 Mini")
    }
}
