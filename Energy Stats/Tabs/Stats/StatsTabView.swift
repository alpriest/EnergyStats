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

enum StatsGraphDisplayMode: Equatable {
    case day(Date)
    case month(_ month: Int, _ year: Int)
    case year(Int)
    case custom(_ start: Date, _ end: Date)

    func unit() -> Calendar.Component {
        switch self {
        case .day:
            return .hour
        case .month:
            return .day
        case .year:
            return .month
        case .custom:
            return .day
        }
    }

    static func ==(lhs: StatsGraphDisplayMode, rhs: StatsGraphDisplayMode) -> Bool {
        switch (lhs, rhs) {
        case let (.day(lDate), .day(rDate)):
            return lDate.isSame(as: rDate)
        case let (.month(lMonth, lYear), .month(rMonth, rYear)):
            return lYear == rYear && lMonth == rMonth
        case let (.year(lYear), .year(rYear)):
            return lYear == rYear
        default:
            return false
        }
    }
}

struct StatsTabView: View {
    @StateObject var viewModel: StatsTabViewModel
    @State private var showingExporter = false
    @State private var appSettings: AppSettings
    private var appSettingsPublisher: LatestAppSettingsPublisher
    @AppStorage("showStatsGraph") private var showingGraph = true

    init(configManager: ConfigManaging, networking: Networking, appSettingsPublisher: LatestAppSettingsPublisher) {
        _viewModel = .init(wrappedValue: StatsTabViewModel(networking: networking, configManager: configManager))
        self.appSettingsPublisher = appSettingsPublisher
        self.appSettings = appSettingsPublisher.value
    }

    var body: some View {
        Group {
            VStack {
                StatsDatePickerView(viewModel: StatsDatePickerViewModel($viewModel.displayMode),
                                    showingGraph: $showingGraph)

                ScrollView {
                    VStack {
                        if showingGraph {
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

                            StatsGraphView(
                                viewModel: viewModel,
                                selectedDate: $viewModel.selectedDate,
                                valuesAtTime: $viewModel.valuesAtTime,
                                appSettings: appSettings
                            )
                            .frame(height: 250)
                            .padding(.vertical)

                        } else {
                            Spacer()
                        }
                    }.loadable(viewModel.state, options: [.retry], overlay: true, retry: { Task { await viewModel.load() } })

                    StatsGraphVariableToggles(viewModel: viewModel, selectedDate: $viewModel.selectedDate, valuesAtTime: $viewModel.valuesAtTime, appSettings: appSettingsPublisher.value)

                    if let approximationsViewModel = viewModel.approximationsViewModel {
                        ApproximationsView(viewModel: approximationsViewModel, appSettings: appSettingsPublisher.value, decimalPlaceOverride: nil)
                    }

                    Text("Stats are aggregated by FoxESS into 1 hr, 1 day or 1 month totals")
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
        }
        .task {
            await viewModel.load()
        }
        .onReceive(appSettingsPublisher) {
            self.appSettings = $0
        }
        .trackVisibility(on: viewModel)
    }
}

#if DEBUG
#Preview {
    StatsTabView(configManager: ConfigManager.preview(), networking: NetworkService.preview(), appSettingsPublisher: CurrentValueSubject(.mock()))
}
#endif
