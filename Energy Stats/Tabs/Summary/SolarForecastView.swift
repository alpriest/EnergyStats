//
//  SummaryTabView2.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/11/2023.
//

import Charts
import Energy_Stats_Core
import SwiftUI

extension SolcastForecastResponse: Identifiable {
    public var id: Double { period_end.timeIntervalSince1970 }
}

struct SolcastConfig: SolcastSolarForecastingConfiguration {
    var resourceId: String = "6f0b-c4ca-8e82-464f"
    var apiKey: String = "naXJZBtGUCUE8wX9a23pCaXxG0o1ub_e"
}

@available(iOS 16.0, *)
struct SolarForecastView: View {
    @State private var data: [SolcastForecastResponse] = []
//    var foo = [
//        SolarForecast(estimate: 0, estimate10: 0, estimate90: 0, period: ISO8601DateFormatter().date(from: "2023-11-14T06:00:00Z")!),
//        SolarForecast(estimate: 0, estimate10: 0, estimate90: 0, period: ISO8601DateFormatter().date(from: "2023-11-14T06:30:00Z")!),
//        SolarForecast(estimate: 0, estimate10: 0, estimate90: 0, period: ISO8601DateFormatter().date(from: "2023-11-14T07:00:00Z")!),
//        SolarForecast(estimate: 0, estimate10: 0, estimate90: 0, period: ISO8601DateFormatter().date(from: "2023-11-14T07:30:00Z")!),
//        SolarForecast(estimate: 0.0084, estimate10: 0.0056, estimate90: 0.0167, period: ISO8601DateFormatter().date(from: "2023-11-14T08:00:00Z")!),
//        SolarForecast(estimate: 0.0501, estimate10: 0.0223, estimate90: 0.0891, period: ISO8601DateFormatter().date(from: "2023-11-14T08:30:00Z")!),
//        SolarForecast(estimate: 0.0975, estimate10: 0.0418, estimate90: 0.1811, period: ISO8601DateFormatter().date(from: "2023-11-14T09:00:00Z")!),
//        SolarForecast(estimate: 0.1635, estimate10: 0.0771, estimate90: 0.4012, period: ISO8601DateFormatter().date(from: "2023-11-14T09:30:00Z")!),
//        SolarForecast(estimate: 0.3364, estimate10: 0.1377, estimate90: 0.746, period: ISO8601DateFormatter().date(from: "2023-11-14T10:00:00Z")!),
//        SolarForecast(estimate: 0.4891, estimate10: 0.2125, estimate90: 1.1081, period: ISO8601DateFormatter().date(from: "2023-11-14T10:30:00Z")!),
//        SolarForecast(estimate: 0.609, estimate10: 0.2531, estimate90: 1.505, period: ISO8601DateFormatter().date(from: "2023-11-14T11:00:00Z")!),
//        SolarForecast(estimate: 0.7061, estimate10: 0.2835, estimate90: 1.8413, period: ISO8601DateFormatter().date(from: "2023-11-14T11:30:00Z")!),
//        SolarForecast(estimate: 0.7667, estimate10: 0.2936, estimate90: 2.09, period: ISO8601DateFormatter().date(from: "2023-11-14T12:00:00Z")!),
//        SolarForecast(estimate: 0.8404, estimate10: 0.3037, estimate90: 2.3005, period: ISO8601DateFormatter().date(from: "2023-11-14T12:30:00Z")!),
//        SolarForecast(estimate: 0.9307, estimate10: 0.3138, estimate90: 2.5050, period: ISO8601DateFormatter().date(from: "2023-11-14T13:00:00Z")!),
//        SolarForecast(estimate: 0.9832, estimate10: 0.3087, estimate90: 2.5392, period: ISO8601DateFormatter().date(from: "2023-11-14T13:30:00Z")!),
//        SolarForecast(estimate: 0.9438, estimate10: 0.2733, estimate90: 2.5179, period: ISO8601DateFormatter().date(from: "2023-11-14T14:00:00Z")!),
//        SolarForecast(estimate: 0.8035, estimate10: 0.1973, estimate90: 2.8682, period: ISO8601DateFormatter().date(from: "2023-11-14T14:30:00Z")!),
//        SolarForecast(estimate: 0.5897, estimate10: 0.128, estimate90: 2.5599, period: ISO8601DateFormatter().date(from: "2023-11-14T15:00:00Z")!),
//        SolarForecast(estimate: 0.1594, estimate10: 0.0716, estimate90: 1.6839, period: ISO8601DateFormatter().date(from: "2023-11-14T15:30:00Z")!),
//        SolarForecast(estimate: 0.0496, estimate10: 0.0248, estimate90: 0.6277, period: ISO8601DateFormatter().date(from: "2023-11-14T16:00:00Z")!),
//        SolarForecast(estimate: 0.0028, estimate10: 0.0028, estimate90: 0.0055, period: ISO8601DateFormatter().date(from: "2023-11-14T16:30:00Z")!),
//        SolarForecast(estimate: 0, estimate10: 0, estimate90: 0, period: ISO8601DateFormatter().date(from: "2023-11-14T17:00:00Z")!),
//        SolarForecast(estimate: 0, estimate10: 0, estimate90: 0, period: ISO8601DateFormatter().date(from: "2023-11-14T17:30:00Z")!),
//        SolarForecast(estimate: 0, estimate10: 0, estimate90: 0, period: ISO8601DateFormatter().date(from: "2023-11-14T18:00:00Z")!),
//        SolarForecast(estimate: 0, estimate10: 0, estimate90: 0, period: ISO8601DateFormatter().date(from: "2023-11-14T18:30:00Z")!),
//        SolarForecast(estimate: 0, estimate10: 0, estimate90: 0, period: ISO8601DateFormatter().date(from: "2023-11-14T19:00:00Z")!),
//        SolarForecast(estimate: 0, estimate10: 0, estimate90: 0, period: ISO8601DateFormatter().date(from: "2023-11-14T19:30:00Z")!),
//        SolarForecast(estimate: 0, estimate10: 0, estimate90: 0, period: ISO8601DateFormatter().date(from: "2023-11-14T20:00:00Z")!),
//        SolarForecast(estimate: 0, estimate10: 0, estimate90: 0, period: ISO8601DateFormatter().date(from: "2023-11-14T20:30:00Z")!),
//    ]
    let service = Solcast(config: SolcastConfig())
    let appTheme: AppTheme

    var body: some View {
        VStack(spacing: 44) {
            VStack(spacing: 8) {
                Text("Solar Forecast Today")
                    .font(.title2)

                ZStack {
                    Chart {
                        ForEach(data) { data in
                            AreaMark(x: .value("Date", data.period_end),
                                     yStart: .value("kWh", data.pv_estimate10),
                                     yEnd: .value("kWh", data.pv_estimate90))
                                .foregroundStyle(Color.yellow.gradient)
                                .opacity(0.2)

                            LineMark(
                                x: .value("Date", data.period_end),
                                y: .value("kWh", data.pv_estimate)
                            )
                            .foregroundStyle(Color.blue)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5], dashPhase: 0))
                        }
                        .interpolationMethod(.catmullRom)
                    }
                    .frame(height: 200)
                }
            }
        }.task {
            Task { self.data = try await service.fetchForecast().forecasts }
        }
    }
}

@available(iOS 16.0, *)
#Preview {
    SolarForecastView(appTheme: AppTheme.mock())
}
