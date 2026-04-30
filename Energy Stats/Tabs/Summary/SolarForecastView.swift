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
    @State private var showSolcastConfiguration = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.hasSites {
                loadedView()
            } else {
                Text("solcast_configuration_motivation")
                Button(action: { showSolcastConfiguration.toggle() }) {
                    Text("Configure Solcast now")
                }
            }
        }.sheet(isPresented: $showSolcastConfiguration) {
            SolcastSettingsView(
                configManager: viewModel.configManager,
                solarService: viewModel.solarForecastProvider
            )
        }
    }

    private func loadedView() -> some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 16) {
                if let data = viewModel.solarForecastAchievedData {
                    solarVsForecastView(data: data)
                }

                Text("Solar Forecasts")
                    .font(.largeTitle)

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
        .transition(.opacity)
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

    @ViewBuilder
    private func solarVsForecastView(data: PercentageSolarForecastAchievedData) -> some View {
        HStack {
            Text("Solar vs forecast")
                .font(.largeTitle)

            Spacer()

            Button {
                viewModel.togglePeriod()
            } label: {
                Text(viewModel.period == .yesterday ? "Yesterday" : "7 days")
            }.buttonStyle(.bordered)
        }

        VStack(alignment: .leading) {
            ESLabeledText("Actual generation", value: data.totalSolarAchieved.kWh(0))
            ESLabeledText("Forecast total", value: data.totalSolarForecast.kWh(0))

            ESLabeledContent("Forecast completeness") {
                HStack {
                    percentageBar(percentage: data.forecastCompleteness)
                    Text(data.forecastCompleteness.percent(maximumFractionDigits: 0))
                }
            }

            Text(data.description)
                .font(.caption)
                .foregroundStyle(Color.textDimmed)
                .padding(.top)
        }
    }

    private func percentageBar(percentage: Double) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(.gray.opacity(0.2))

            RoundedRectangle(cornerRadius: 2)
                .fill(.blue)
                .frame(width: min(1.0, percentage) * (100 - 4))
                .padding(2)
        }
        .frame(width: 100, height: 14)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray)
        )
    }
}

#Preview {
    SolarForecastView(
        appSettings: AppSettings.mock(),
        viewModel: SolarForecastViewModel(
            configManager: ConfigManager.preview(),
            solarForecastProvider: { PreviewSolcast() },
            networking: NetworkService.preview()
        )
    )
    .environment(\.locale, .init(identifier: "de"))
}
