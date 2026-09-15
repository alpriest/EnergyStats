//
//  SummaryTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/11/2023.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct SummaryTabView: View {
    @State private var viewModel: SummaryTabViewModel?
    @State private var appSettings: AppSettings
    @State private var presentSheet = false
    private var appSettingsPublisher: LatestAppSettingsPublisher
    private let configManager: ConfigManaging
    private let networking: Networking
    private let solarForecastProvider: SolarForecastProviding

    init(configManager: ConfigManaging, networking: Networking, solarForecastProvider: @escaping SolarForecastProviding) {
        self.configManager = configManager
        self.networking = networking
        self.solarForecastProvider = solarForecastProvider
        self.appSettingsPublisher = configManager.appSettingsPublisher
        self.appSettings = configManager.currentAppSettings
    }

    var body: some View {
        NavigationStack {
            if let viewModel {
                ScrollView {
                    VStack(alignment: .leading) {
                        if let viewData = viewModel.viewData {
                            SummaryLoadedView(viewData: viewData, appSettings: appSettings, onToggleBestSolar: viewModel.toggleBestSolarGrouping)
                        } else {
                            Text("Could not load approximations")
                        }

                        Divider()

                        SolarForecastView(
                            appSettings: appSettings,
                            configManager: configManager,
                            networking: networking,
                            solarForecastProvider: solarForecastProvider
                        )
                    }
                }
                .padding(.horizontal)
                .navigationTitle("summary_title")
                .analyticsScreen(.summary)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { presentSheet.toggle() },
                               label: { Text("Edit") }).buttonStyle(.plain)
                    }
                }
                .sheet(isPresented: $presentSheet) {
                    SummaryDateRangeView(initial: viewModel.summaryDateRange, onApply: { dateRange in
                        viewModel.setDateRange(dateRange: dateRange)
                    })
                    .presentationDetents([.medium])
                }
                .loadable(viewModel.state, retry: { viewModel.load() })
            }
        }
        .onAppear {
            viewModel = SummaryTabViewModel(configManager: configManager, networking: networking)
            viewModel?.load()
        }
        .onReceive(appSettingsPublisher) {
            self.appSettings = $0
        }
    }
}

#Preview {
    SummaryTabView(configManager: ConfigManager.preview(),
                   networking: NetworkService.preview(),
                   solarForecastProvider: { DemoSolcast() })
}
