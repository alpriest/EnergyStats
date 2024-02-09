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

enum StatsDisplayMode: Equatable {
    case day(Date)
    case month(_ month: Int, _ year: Int)
    case year(Int)

    func unit() -> Calendar.Component {
        switch self {
        case .day:
            return .hour
        case .month:
            return .day
        case .year:
            return .month
        }
    }
}

struct StatsTabView: View {
    @StateObject var viewModel: StatsTabViewModel
    @State private var showingExporter = false
    @State private var appSettings: AppSettings
    private var appSettingsPublisher: LatestAppSettingsPublisher
    @AppStorage("showStatsGraph") private var showingGraph = true

    init(configManager: ConfigManaging, networking: FoxESSNetworking, appSettingsPublisher: LatestAppSettingsPublisher) {
        _viewModel = .init(wrappedValue: StatsTabViewModel(networking: networking, configManager: configManager))
        self.appSettingsPublisher = appSettingsPublisher
        self.appSettings = appSettingsPublisher.value
    }

    var body: some View {
        Group {
            VStack {
                DatePickerView(viewModel: DatePickerViewModel($viewModel.displayMode),
                               showingGraph: $showingGraph)

                ScrollView {
                    VStack {
                        if showingGraph {
                            if #available(iOS 16.0, *) {
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
                                            Text("Touch the graph to see values at that time")
                                        }
                                    }.padding(.vertical)
                                }.frame(maxWidth: .infinity)

                                StatsGraphView(viewModel: viewModel, selectedDate: $viewModel.selectedDate, valuesAtTime: $viewModel.valuesAtTime)
                                    .frame(height: 250)
                                    .padding(.vertical)
                            }
                        } else {
                            Spacer()
                        }
                    }.loadable(viewModel.state, overlay: true, retry: { Task { await viewModel.load() } })

                    StatsGraphVariableToggles(viewModel: viewModel, selectedDate: $viewModel.selectedDate, valuesAtTime: $viewModel.valuesAtTime, appSettings: appSettingsPublisher.value)

                    if let approximationsViewModel = viewModel.approximationsViewModel {
                        ApproximationsView(viewModel: approximationsViewModel, appSettings: appSettingsPublisher.value, decimalPlaceOverride: nil)
                    }

                    Text("Stats are aggregated by FoxESS into 1 hr, 1 day or 1 month totals")
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
        .task {
            await viewModel.load()
        }
        .onReceive(appSettingsPublisher) {
            self.appSettings = $0
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview {
    StatsTabView(configManager: PreviewConfigManager(), networking: DemoNetworking(), appSettingsPublisher: CurrentValueSubject(.mock()))
        .previewDevice("iPhone 13 Mini")
}
#endif
