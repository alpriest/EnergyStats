//
//  ParametersGraphTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Charts
import Combine
import Energy_Stats_Core
import SwiftUI

@available(iOS 16.0, *)
struct ParametersGraphTabView: View {
    @StateObject var viewModel: ParametersGraphTabViewModel
    @State private var valuesAtTime: ValuesAtTime<ParameterGraphValue>?
    @State private var selectedDate: Date?
    @State private var showingVariables = false
    @State private var showingExporter = false
    @State private var appTheme: AppTheme = .mock()
    private let appThemePublisher: LatestAppTheme
    private let configManager: ConfigManaging

    init(configManager: ConfigManaging, networking: Networking, dateProvider: @escaping () -> Date = { Date() }) {
        _viewModel = .init(wrappedValue: ParametersGraphTabViewModel(networking: networking, configManager: configManager, dateProvider: dateProvider))
        self.configManager = configManager
        self.appThemePublisher = configManager.appTheme
        self.appTheme = appThemePublisher.value
    }

    var body: some View {
        Group {
            VStack {
                ParameterGraphHeaderView(viewModel: ParameterGraphHeaderViewModel(displayMode: $viewModel.displayMode), showingVariables: $showingVariables)
                    .padding(.horizontal)

                ScrollView {
                    HStack {
                        Group {
                            if let selectedDate {
                                Text(selectedDate, format: .dateTime)
                                Button("Clear graph values", action: {
                                    self.valuesAtTime = nil
                                    self.selectedDate = nil
                                })
                            } else {
                                Text("Touch the graph to see values at that time")
                            }
                        }.padding(.vertical)
                    }.frame(maxWidth: .infinity)

                    ParametersGraphView(viewModel: viewModel,
                                        selectedDate: $selectedDate,
                                        valuesAtTime: $valuesAtTime)
                        .frame(height: 250)
                        .padding(.vertical)

                    ParameterGraphVariablesToggles(viewModel: viewModel, selectedDate: $selectedDate, valuesAtTime: $valuesAtTime, appTheme: appTheme)

                    Text("Parameters are updated every 5 minutes by FoxESS and only available for a single day at a time")
                        .font(.footnote)
                        .foregroundColor(Color("text_dimmed"))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 28)

                    if let url = viewModel.exportFile?.url {
                        ShareLink(item: url) {
                            Label("Export graph data", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingVariables) {
            ParameterGraphVariableChooserView(viewModel: ParameterGraphVariableChooserViewModel(variables: viewModel.graphVariables, configManager: configManager,  onApply: { viewModel.set(graphVariables: $0) }))
        }
        .task {
            Task {
                await viewModel.load()
            }
        }
        .onReceive(appThemePublisher) {
            self.appTheme = $0
        }
    }
}

@available(iOS 16.0, *)
struct GraphTabView_Previews: PreviewProvider {
    static var previews: some View {
        ParametersGraphTabView(configManager: PreviewConfigManager(),
                               networking: DemoNetworking())
            .previewDevice("iPhone 13 Mini")
    }
}
