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
    public var id: Double { period_end.timeIntervalSince1970 }
}

@available(iOS 16.0, *)
struct SolarForecastView: View {
    let appTheme: AppTheme
    @ObservedObject var viewModel: SolarForecastViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Solar Forecasts")
                .font(.largeTitle)

            if viewModel.hasConfig {
                loadedView()
            } else {
                Text("Visit the settings tab to configure Solcast")
            }
        }
    }

    private func loadedView() -> some View {
        VStack(spacing: 8) {
            VStack(spacing: 22) {
                ForecastView(data: viewModel.today, appTheme: appTheme, title: "Today")
                ForecastView(data: viewModel.tomorrow, appTheme: appTheme, title: "Tomorrow")

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
        .loadable($viewModel.state, retry: { viewModel.load() })
        .onAppear {
            self.viewModel.load()
        }
    }
}

@available(iOS 16.0, *)
struct ForecastView: View {
    let data: [SolcastForecastResponse]
    let appTheme: AppTheme
    let title: String

    var body: some View {
        Chart {
            ForEach(data) { data in
                AreaMark(x: .value("Time", data.period_end),
                         yStart: .value("kWh", data.pv_estimate10),
                         yEnd: .value("kWh", data.pv_estimate90))
                    .foregroundStyle(Color.yellow.gradient.opacity(0.2))

                LineMark(
                    x: .value("Time", data.period_end),
                    y: .value("kWh", data.pv_estimate)
                )
                .foregroundStyle(Color.blue)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5], dashPhase: 0))
            }
            .interpolationMethod(.catmullRom)
        }
        .chartLegend(.hidden)
        .chartPlotStyle { content in
            content
                .background(Color.gray.gradient.opacity(0.04))
                .overlay {
                    Text(title)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .foregroundStyle(.black)
                }
        }
        .chartXAxis(content: {
            AxisMarks(values: .stride(by: .hour)) { value in
                if (value.index == 0) || (value.index % 4 == 0), let date = value.as(Date.self) {
                    AxisTick(centered: false)
                    AxisValueLabel(centered: false) {
                        Text(date, format: .dateTime.hour())
                    }
                }
            }
        })
        .chartYAxis(content: {
            AxisMarks { value in
                if let amount = value.as(Double.self) {
                    AxisValueLabel {
                        EnergyText(amount: amount, appTheme: appTheme, type: .default, decimalPlaceOverride: 0)
                    }
                }
            }
        })
        .frame(height: 200)
    }
}

@available(iOS 16.0, *)
#Preview {
    SolarForecastView(appTheme: AppTheme.mock(), viewModel: SolarForecastViewModel(configManager: PreviewConfigManager(), appTheme: CurrentValueSubject(AppTheme.mock())))
}

private class PreviewSolcast: SolarForecasting {
    func fetchForecast() async throws -> SolcastForecastResponseList {
        SolcastForecastResponseList(forecasts: [
            SolcastForecastResponse(pv_estimate: 0, pv_estimate10: 0, pv_estimate90: 0, period_end: ISO8601DateFormatter().date(from: "2023-11-14T06:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0, pv_estimate10: 0, pv_estimate90: 0, period_end: ISO8601DateFormatter().date(from: "2023-11-14T06:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0, pv_estimate10: 0, pv_estimate90: 0, period_end: ISO8601DateFormatter().date(from: "2023-11-14T07:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0, pv_estimate10: 0, pv_estimate90: 0, period_end: ISO8601DateFormatter().date(from: "2023-11-14T07:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.0084, pv_estimate10: 0.0056, pv_estimate90: 0.0167, period_end: ISO8601DateFormatter().date(from: "2023-11-14T08:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.0501, pv_estimate10: 0.0223, pv_estimate90: 0.0891, period_end: ISO8601DateFormatter().date(from: "2023-11-14T08:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.0975, pv_estimate10: 0.0418, pv_estimate90: 0.1811, period_end: ISO8601DateFormatter().date(from: "2023-11-14T09:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.1635, pv_estimate10: 0.0771, pv_estimate90: 0.4012, period_end: ISO8601DateFormatter().date(from: "2023-11-14T09:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.3364, pv_estimate10: 0.1377, pv_estimate90: 0.746, period_end: ISO8601DateFormatter().date(from: "2023-11-14T10:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.4891, pv_estimate10: 0.2125, pv_estimate90: 1.1081, period_end: ISO8601DateFormatter().date(from: "2023-11-14T10:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.609, pv_estimate10: 0.2531, pv_estimate90: 1.505, period_end: ISO8601DateFormatter().date(from: "2023-11-14T11:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.7061, pv_estimate10: 0.2835, pv_estimate90: 1.8413, period_end: ISO8601DateFormatter().date(from: "2023-11-14T11:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.7667, pv_estimate10: 0.2936, pv_estimate90: 2.09, period_end: ISO8601DateFormatter().date(from: "2023-11-14T12:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.8404, pv_estimate10: 0.3037, pv_estimate90: 2.3005, period_end: ISO8601DateFormatter().date(from: "2023-11-14T12:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.9307, pv_estimate10: 0.3138, pv_estimate90: 2.5050, period_end: ISO8601DateFormatter().date(from: "2023-11-14T13:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.9832, pv_estimate10: 0.3087, pv_estimate90: 2.5392, period_end: ISO8601DateFormatter().date(from: "2023-11-14T13:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.9438, pv_estimate10: 0.2733, pv_estimate90: 2.5179, period_end: ISO8601DateFormatter().date(from: "2023-11-14T14:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.8035, pv_estimate10: 0.1973, pv_estimate90: 2.8682, period_end: ISO8601DateFormatter().date(from: "2023-11-14T14:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.5897, pv_estimate10: 0.128, pv_estimate90: 2.5599, period_end: ISO8601DateFormatter().date(from: "2023-11-14T15:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.1594, pv_estimate10: 0.0716, pv_estimate90: 1.6839, period_end: ISO8601DateFormatter().date(from: "2023-11-14T15:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.0496, pv_estimate10: 0.0248, pv_estimate90: 0.6277, period_end: ISO8601DateFormatter().date(from: "2023-11-14T16:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0.0028, pv_estimate10: 0.0028, pv_estimate90: 0.0055, period_end: ISO8601DateFormatter().date(from: "2023-11-14T16:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0, pv_estimate10: 0, pv_estimate90: 0, period_end: ISO8601DateFormatter().date(from: "2023-11-14T17:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0, pv_estimate10: 0, pv_estimate90: 0, period_end: ISO8601DateFormatter().date(from: "2023-11-14T17:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0, pv_estimate10: 0, pv_estimate90: 0, period_end: ISO8601DateFormatter().date(from: "2023-11-14T18:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0, pv_estimate10: 0, pv_estimate90: 0, period_end: ISO8601DateFormatter().date(from: "2023-11-14T18:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0, pv_estimate10: 0, pv_estimate90: 0, period_end: ISO8601DateFormatter().date(from: "2023-11-14T19:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0, pv_estimate10: 0, pv_estimate90: 0, period_end: ISO8601DateFormatter().date(from: "2023-11-14T19:30:00Z")!),
            SolcastForecastResponse(pv_estimate: 0, pv_estimate10: 0, pv_estimate90: 0, period_end: ISO8601DateFormatter().date(from: "2023-11-14T20:00:00Z")!),
            SolcastForecastResponse(pv_estimate: 0, pv_estimate10: 0, pv_estimate90: 0, period_end: ISO8601DateFormatter().date(from: "2023-11-14T20:30:00Z")!)
        ])
    }
}
