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
    @StateObject var viewModel: ParametersGraphTabViewModel
    @State private var valuesAtTime: ValuesAtTime<ParameterGraphValue>?
    @State private var selectedDate: Date?
    @State private var showingVariables = false
    @State private var showingExporter = false
    @State private var appSettings: AppSettings = .mock()
    private let appSettingsPublisher: LatestAppSettingsPublisher
    private let configManager: ConfigManaging

    init(configManager: ConfigManaging, networking: Networking, dateProvider: @escaping () -> Date = { Date() }) {
        _viewModel = .init(wrappedValue: ParametersGraphTabViewModel(networking: networking, configManager: configManager, dateProvider: dateProvider))
        self.configManager = configManager
        self.appSettingsPublisher = configManager.appSettingsPublisher
        self.appSettings = appSettingsPublisher.value
    }

    var body: some View {
        Group {
            VStack {
                ParameterGraphHeaderView(viewModel: ParameterGraphHeaderViewModel(displayMode: $viewModel.displayMode), showingVariables: $showingVariables)
                    .padding(.horizontal)

                ScrollView {
                    if #available(iOS 16.0, *) {
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

                        if configManager.separateParameterGraphsByUnit {
                            VStack {
                                ForEach(Array(viewModel.data.keys.sorted { $0 < $1 }), id: \.self) { key in
                                    ZStack {
                                        ParametersGraphView(key: key,
                                                            viewModel: viewModel,
                                                            selectedDate: $selectedDate,
                                                            valuesAtTime: $valuesAtTime)
                                            .frame(height: 250)
                                            .padding(.vertical)

                                        LoadingView(message: "Loading")
                                            .opacity(viewModel.state.opacity())
                                    }
                                }
                            }
                        } else {
                            ZStack {
                                ParametersGraphView(key: nil,
                                                    viewModel: viewModel,
                                                    selectedDate: $selectedDate,
                                                    valuesAtTime: $valuesAtTime)
                                    .frame(height: 250)
                                    .padding(.vertical)

                                LoadingView(message: "Loading")
                                    .opacity(viewModel.state.opacity())
                            }
                        }
                    }

                    ParameterGraphVariablesToggles(viewModel: viewModel, selectedDate: $selectedDate, valuesAtTime: $valuesAtTime, appSettings: appSettings)

                    Text("Parameters are updated every 5 minutes by FoxESS and only available for a single day at a time")
                        .font(.footnote)
                        .foregroundColor(Color("text_dimmed"))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 28)

                    if #available(iOS 16.0, *) {
                        if let url = viewModel.exportFile?.url {
                            ShareLink(item: url) {
                                Label("Export graph data", systemImage: "square.and.arrow.up")
                            }
                        }
                    }

                    if #available(iOS 16.0, *) {
                    } else {
                        Text("Graph functionality requires iOS 16 or newer")
                            .font(.footnote)
                            .foregroundColor(Color("text_dimmed"))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding()
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
    }
}

@available(iOS 16.0, *)
struct GraphTabView_Previews: PreviewProvider {
    static var previews: some View {
        ParametersGraphTabView(configManager: ConfigManager.preview(),
                               networking: NetworkService.preview())
            .previewDevice("iPhone 13 Mini")
    }
}
