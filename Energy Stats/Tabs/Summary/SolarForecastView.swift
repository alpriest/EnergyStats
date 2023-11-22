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

extension SolcastForecastResponse: Identifiable {
    public var id: Double { periodEnd.timeIntervalSince1970 }
}

@available(iOS 16.0, *)
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
                    .font(.footnote)
                }
            }
        }
        .loadable($viewModel.state, retry: { viewModel.load() })
        .onAppear {
            self.viewModel.load()
        }
    }
}
