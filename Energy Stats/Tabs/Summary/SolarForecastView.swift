//
//  SummaryTabView2.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/11/2023.
//

import Charts
import Combine
import Energy_Stats_Core
import SwiftUI

struct SolarForecastView: View {
    let appSettings: AppSettings
    @ObservedObject var viewModel: SolarForecastViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Solar Forecasts")
                .font(.largeTitle)

            if viewModel.hasSites {
                loadedView()
            } else {
                Text("Visit the settings tab to configure Solcast")
            }
        }
    }

    private func loadedView() -> some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 22) {
                ForEach(viewModel.data) { site in
                    ForecastView(
                        data: site.today,
                        total: site.todayTotal,
                        appSettings: appSettings,
                        name: site.name,
                        title: "Forecast today",
                        yAxisDecimalPlaces: appSettings.decimalPlaces,
                        error: site.error,
                        resourceId: site.resourceId
                    )
                }

                ForEach(viewModel.data) { site in
                    ForecastView(
                        data: site.tomorrow,
                        total: site.tomorrowTotal,
                        appSettings: appSettings,
                        name: site.name,
                        title: "Forecast tomorrow",
                        yAxisDecimalPlaces: appSettings.decimalPlaces,
                        error: site.error,
                        resourceId: site.resourceId
                    )
                }

                if viewModel.data.anySatisfy({ $0.error == nil }) {
                    VStack(alignment: .center) {
                        HStack {
                            MidYHorizontalLine()
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 5], dashPhase: 0))
                                .foregroundStyle(Color.blue)
                                .frame(width: 20, height: 5)

                            Text("Prediction")

                            Rectangle()
                                .foregroundStyle(Color.yellow.gradient.opacity(0.2))
                                .frame(width: 20, height: 15)

                            Text("Range of confidence")
                        }
                        .padding(.top)

                        if let date = viewModel.lastFetched {
                            Text("Last update") + Text(" ") + Text(date, format: .dateTime)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .font(.footnote)
                }
                refreshSolcastButton()
            }
        }
        .loadable(viewModel.state, options: [], errorAlertType: .solcast, retry: { viewModel.load() })
        .onAppear {
            self.viewModel.load()
        }
    }

    private func refreshSolcastButton() -> some View {
        VStack(alignment: .leading) {
            if viewModel.tooManyRequests {
                Text("You have exceeded your free daily limit of requests. Please try tomorrow.")
            } else {
                Button {
                    viewModel.refetchSolcast()
                } label: {
                    Text("Refresh Solcast now")
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.canRefresh)

                if !viewModel.canRefresh {
                    Text("Due to Solcast API rate limiting, please wait for an hour before refreshing again.")
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 32)
    }
}

#Preview {
    SolarForecastView(
        appSettings: AppSettings.mock(),
        viewModel: SolarForecastViewModel(
            configManager: ConfigManager.preview(),
            appSettingsPublisher: AppSettingsPublisherFactory.make(),
            solarForecastProvider: { PreviewSolcast() }
        )
    )
}
