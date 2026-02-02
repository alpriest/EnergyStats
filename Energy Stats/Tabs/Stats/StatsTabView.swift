//
//  StatsTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import Charts
import Combine
import Energy_Stats_Core
import SwiftUI

struct StatsTabView: View {
    @StateObject var viewModel: StatsTabViewModel
    @State private var showingExporter = false
    @State private var appSettings: AppSettings
    private var appSettingsPublisher: LatestAppSettingsPublisher
    @AppStorage("showStatsGraph") private var showingTimeGraph = true
    @AppStorage("showingEnergyBreakdownGraph") private var showingEnergyBreakdownGraph = true

    init(configManager: ConfigManaging, networking: Networking) {
        _viewModel = .init(wrappedValue: StatsTabViewModel(networking: networking, configManager: configManager))
        self.appSettingsPublisher = configManager.appSettingsPublisher
        self.appSettings = configManager.currentAppSettings
    }

    var body: some View {
        Group {
            VStack {
                StatsDatePickerHeaderView(viewModel: StatsDatePickerHeaderViewModel($viewModel.displayMode),
                                          showingTimeGraph: $showingTimeGraph,
                                          showingEnergyBreakdownGraph: $showingEnergyBreakdownGraph)

                ScrollView {
                    VStack {
                        if showingTimeGraph {
                            HStack {
                                Group {
                                    if viewModel.valuesAtTime != nil, let selectedDate = viewModel.selectedDate {
                                        Text(viewModel.selectedDateFormatted(selectedDate))

                                        Button("Clear graph values", action: {
                                            self.viewModel.valuesAtTime = nil
                                            self.viewModel.selectedDate = nil
                                            self.viewModel.calculateApproximations()
                                        })
                                    } else {
                                        Text(viewModel.touchHeaderTitle)
                                    }
                                }
                                .padding(.vertical)
                                .font(.caption)
                            }.frame(maxWidth: .infinity)

                            StatsGraphView(
                                viewModel: viewModel,
                                selectedDate: $viewModel.selectedDate,
                                valuesAtTime: $viewModel.valuesAtTime,
                                appSettings: appSettings
                            )
                            .frame(height: graphHeight)
                        }

                        if showingEnergyBreakdownGraph {
                            EnergyBreakdownChart(.init(viewModel: viewModel))
                                .frame(height: graphHeight)
                        }
                    }.loadable(viewModel.state, options: [.retry], overlay: true, retry: { Task { await viewModel.load() } })

                    StatsGraphVariableToggles(viewModel: viewModel, selectedDate: $viewModel.selectedDate, valuesAtTime: $viewModel.valuesAtTime, appSettings: appSettings)

                    if let approximationsViewModel = viewModel.approximationsViewModel {
                        ApproximationsView(viewModel: approximationsViewModel, appSettings: appSettings, decimalPlaceOverride: nil)
                    }

                    Text("Stats are aggregated by FoxESS into 1 hr, 1 day or 1 month totals.")
                        .font(.footnote)
                        .foregroundColor(Color("text_dimmed"))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 28)

                    if let url = viewModel.exportFile?.url {
                        ShareLink(item: url) {
                            Label("Export graph data", systemImage: "square.and.arrow.up")
                        }
                        .padding(.bottom)
                    }
                }
            }
            .padding(.horizontal)
            .analyticsScreen(.statsTab)
        }
        .tipKit(tip: .statsPageEnergyBalanceChartAdded)
        .task {
            await viewModel.load()
        }
        .onReceive(appSettingsPublisher) {
            self.appSettings = $0
        }
        .trackVisibility(on: viewModel)
    }

    private var graphHeight: CGFloat {
        switch (showingTimeGraph, showingEnergyBreakdownGraph) {
        case (true, true):
            200
        case (false, false):
            0
        default:
            300
        }
    }
}

#if DEBUG
#Preview {
    StatsTabView(
        configManager: ConfigManager.preview(),
        networking: NetworkService.preview()
    )
}
#endif
