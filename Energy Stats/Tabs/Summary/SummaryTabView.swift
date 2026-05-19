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
    @StateObject var viewModel: SummaryTabViewModel
    @State private var appSettings: AppSettings
    private var appSettingsPublisher: LatestAppSettingsPublisher
    private let configManager: ConfigManaging
    @StateObject private var solarForecastViewModel: SolarForecastViewModel
    @State private var presentSheet = false

    init(configManager: ConfigManaging, networking: Networking, solarForecastProvider: @escaping SolarForecastProviding) {
        self.configManager = configManager
        _viewModel = .init(wrappedValue: SummaryTabViewModel(configManager: configManager, networking: networking))
        _solarForecastViewModel = .init(wrappedValue: SolarForecastViewModel(configManager: configManager, solarForecastProvider: solarForecastProvider, networking: networking))
        self.appSettingsPublisher = configManager.appSettingsPublisher
        self.appSettings = configManager.currentAppSettings
    }

    var body: some View {
        NavigationStack {
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
                        viewModel: solarForecastViewModel
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
        .onAppear { viewModel.load() }
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
