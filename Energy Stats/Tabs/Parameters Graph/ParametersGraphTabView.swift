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

struct ParametersGraphTabView: View {
    @State private var valuesAtTime: ValuesAtTime<ParameterGraphValue>?
    @State private var selectedDate: Date?
    @State private var showingVariables = false
    @State private var showingExporter = false
    @State private var appSettings: AppSettings = .mock()
    private let appSettingsPublisher: LatestAppSettingsPublisher
    private let configManager: ConfigManaging
    @ObservedObject var viewModel: ParametersGraphTabViewModel

    init(configManager: ConfigManaging, viewModel: ParametersGraphTabViewModel) {
        self.viewModel = viewModel
        self.configManager = configManager
        self.appSettingsPublisher = configManager.appSettingsPublisher
        self.appSettings = appSettingsPublisher.value
    }

    var body: some View {
        Group {
            VStack {
                ParameterGraphHeaderView(
                    viewModel: ParameterGraphHeaderViewModel(displayMode: viewModel.displayMode, configManager: configManager, onChange: { viewModel.displayMode = $0 }),
                    showingVariables: $showingVariables
                )

                ScrollView {
                    HStack {
                        if let selectedDate {
                            Text(selectedDate, format: .dateTime)
                            Button("Clear graph values", action: {
                                self.valuesAtTime = nil
                                self.selectedDate = nil
                            })
                        } else {
                            Text("Touch the graph to see values at that time")
                        }
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)

                    if viewModel.hasLoaded {
                        graphs()
                    } else {
                        LoadingView(message: "Loading")
                            .loadable(viewModel.state, options: [.retry], overlay: true, retry: { Task { await viewModel.load() } })
                    }

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
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingVariables) {
            ParameterGraphVariableChooserView(viewModel: ParameterGraphVariableChooserViewModel(variables: viewModel.graphVariables, configManager: configManager, onApply: { viewModel.set(graphVariables: $0) }))
        }
        .task {
            await viewModel.load()
        }
        .onReceive(appSettingsPublisher) {
            self.appSettings = $0
        }
        .trackVisibility(on: viewModel)
        .navigationTitle(.parametersTab)
    }

    private func graphs() -> some View {
        Group {
            if configManager.separateParameterGraphsByUnit {
                VStack {
                    ForEach(Array(viewModel.uniqueSelectedUnits()), id: \.self) { key in
                        ZStack {
                            VStack {
                                ParametersGraphView(unit: key,
                                                    viewModel: viewModel,
                                                    selectedDate: $selectedDate,
                                                    valuesAtTime: $valuesAtTime,
                                                    truncateYAxis: appSettings.truncatedYAxisOnParameterGraphs)
                                    .frame(height: 250)
                                    .padding(.vertical)

                                ParameterGraphVariablesToggles(
                                    viewModel: viewModel,
                                    selectedDate: $selectedDate,
                                    valuesAtTime: $valuesAtTime,
                                    appSettings: appSettings,
                                    filter: key
                                )
                            }

                            LoadingView(message: "Loading")
                                .opacity(viewModel.state.opacity())
                        }
                    }
                }
            } else {
                ZStack {
                    VStack {
                        ParametersGraphView(unit: nil,
                                            viewModel: viewModel,
                                            selectedDate: $selectedDate,
                                            valuesAtTime: $valuesAtTime,
                                            truncateYAxis: appSettings.truncatedYAxisOnParameterGraphs)
                            .frame(height: 250)
                            .padding(.vertical)

                        ParameterGraphVariablesToggles(
                            viewModel: viewModel,
                            selectedDate: $selectedDate,
                            valuesAtTime: $valuesAtTime,
                            appSettings: appSettings,
                            filter: nil
                        )
                    }

                    LoadingView(message: "Loading")
                        .opacity(viewModel.state.opacity())
                }
            }
        }
    }
}

struct GraphTabView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ParametersGraphTabViewModel(
            networking: NetworkService.preview(),
            configManager: ConfigManager.preview(),
            solarForecastProvider: { PreviewSolcast() }
        )

        return ParametersGraphTabView(configManager: ConfigManager.preview(),
                                      viewModel: viewModel)
            .previewDevice("iPhone 13 Mini")
    }
}
