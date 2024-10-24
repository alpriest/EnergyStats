//
//  ForecastView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/11/2023.
//

import Charts
import Energy_Stats_Core
import SwiftUI

struct ForecastView: View {
    @State private var size: CGSize = .zero
    private let data: [SolcastForecastResponse]
    private let total: Double
    private let appSettings: AppSettings
    private let title: LocalizedStringKey
    private let xScale: ClosedRange<Date>
    private let name: String?
    private let yAxisDecimalPlaces: Int
    private let error: String?
    private let resourceId: String

    init(data: [SolcastForecastResponse], total: Double, appSettings: AppSettings, name: String?, title: LocalizedStringKey, yAxisDecimalPlaces: Int, error: String?, resourceId: String) {
        self.data = data
        self.total = total
        self.appSettings = appSettings
        self.name = name
        self.title = title
        self.yAxisDecimalPlaces = yAxisDecimalPlaces
        self.error = error
        self.resourceId = resourceId

        if let graphDate = data.first?.periodEnd {
            let startDate = Calendar.current.startOfDay(for: graphDate)
            let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
            self.xScale = Calendar.current.startOfDay(for: startDate)...endDate
        } else {
            self.xScale = Date()...Date()
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let error {
                errorView(text: error)
            } else {
                graphView()
            }
        }
    }

    @ViewBuilder
    private func errorView(text: String) -> some View {
        HStack(spacing: 0) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.red)

            VStack(alignment: .leading) {
                Text("Resource Id: \(resourceId)")

                Text(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.caption)
            .foregroundStyle(Color.secondary)
        }
    }

    @ViewBuilder
    private func graphView() -> some View {
        HStack(spacing: 3) {
            OptionalView(name) {
                Text($0)
                    .bold()
            }

            Text(title)

            EnergyText(amount: total, appSettings: appSettings, type: .default)
        }
        .foregroundStyle(Color(uiColor: .label))
        .font(.caption)

        Chart {
            ForEach(data) { data in
                AreaMark(x: .value("Time", data.periodEnd),
                         yStart: .value("kWh", data.pvEstimate10),
                         yEnd: .value("kWh", data.pvEstimate90))
                    .foregroundStyle(Color.yellow.gradient.opacity(0.2))

                LineMark(
                    x: .value("Time", data.periodEnd),
                    y: .value("kWh", data.pvEstimate)
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
        }
        .chartOverlay { chartProxy in
            GeometryReader { geometryReader in
                if let elementLocation = chartProxy.position(forX: Date()) {
                    let location = elementLocation - geometryReader[chartProxy.plotAreaFrame].origin.x

                    Rectangle()
                        .fill(Color.pink.opacity(0.5))
                        .frame(width: 1, height: chartProxy.plotAreaSize.height * 0.92)
                        .offset(x: location, y: chartProxy.plotAreaSize.height * 0.07)

                    Text("now")
                        .background(GeometryReader(content: { reader in
                            Color.clear.onAppear { size = reader.size }.onChange(of: reader.size) { newValue in size = newValue }
                        }))
                        .font(.caption2)
                        .foregroundStyle(Color.pink.opacity(0.5))
                        .offset(x: location - size.width / 2, y: 0)
                }
            }
        }
        .chartXScale(domain: xScale)
        .chartXAxis(content: {
            AxisMarks(values: .stride(by: .hour, count: 4)) { value in
                if let date = value.as(Date.self) {
                    AxisTick(centered: false)
                    AxisValueLabel(centered: false) {
                        Text(date, format: .dateTime.hour())
                    }
                }
            }
        })
        .chartYAxis(content: {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                if let amount = value.as(Double.self) {
                    AxisGridLine()
                    AxisValueLabel {
                        PowerText(amount: amount, appSettings: appSettings, type: .default, decimalPlaceOverride: yAxisDecimalPlaces)
                    }
                }
            }
        })
        .frame(height: 200)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 22) {
                ForecastView(data: PreviewSolcast().fetchForecast().forecasts,
                             total: 5.0,
                             appSettings: AppSettings.mock(),
                             name: "bob",
                             title: "Forecast today",
                             yAxisDecimalPlaces: 2,
                             error: nil,
                             resourceId: "abc-123-def-456")
            }
        }
    }.padding()
}

class PreviewSolcast: SolcastCaching {
    func fetchSites(apiKey: String) async throws -> SolcastSiteResponseList {
        SolcastSiteResponseList(
            sites: [
                SolcastSiteResponse(
                    name: "name",
                    resourceId: "resourceId",
                    capacity: 0.0,
                    longitude: 0.0,
                    latitude: 0.0,
                    azimuth: 1,
                    tilt: 0.0,
                    lossFactor: nil,
                    dcCapacity: nil,
                    installDate: nil
                )
            ]
        )
    }

    func fetchForecast(for site: SolcastSite, apiKey: String, ignoreCache: Bool) async throws -> SolcastForecastList {
        SolcastForecastList(tooManyRequests: false, forecasts: [])
    }

    func fetchForecast() -> SolcastForecastResponseList {
        SolcastForecastResponseList(forecasts: [
            SolcastForecastResponse(pvEstimate: 0, pvEstimate10: 0, pvEstimate90: 0, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T06:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0, pvEstimate10: 0, pvEstimate90: 0, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T06:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0, pvEstimate10: 0, pvEstimate90: 0, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T07:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0, pvEstimate10: 0, pvEstimate90: 0, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T07:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.0084, pvEstimate10: 0.0056, pvEstimate90: 0.0167, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T08:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.0501, pvEstimate10: 0.0223, pvEstimate90: 0.0891, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T08:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.0975, pvEstimate10: 0.0418, pvEstimate90: 0.1811, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T09:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.1635, pvEstimate10: 0.0771, pvEstimate90: 0.4012, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T09:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.3364, pvEstimate10: 0.1377, pvEstimate90: 0.746, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T10:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.4891, pvEstimate10: 0.2125, pvEstimate90: 1.1081, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T10:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.609, pvEstimate10: 0.2531, pvEstimate90: 1.505, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T11:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.7061, pvEstimate10: 0.2835, pvEstimate90: 1.8413, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T11:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.7667, pvEstimate10: 0.2936, pvEstimate90: 2.09, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T12:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.8404, pvEstimate10: 0.3037, pvEstimate90: 2.3005, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T12:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.9307, pvEstimate10: 0.3138, pvEstimate90: 2.5050, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T13:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.9832, pvEstimate10: 0.3087, pvEstimate90: 2.5392, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T13:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.9438, pvEstimate10: 0.2733, pvEstimate90: 2.5179, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T14:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.8035, pvEstimate10: 0.1973, pvEstimate90: 2.8682, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T14:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.5897, pvEstimate10: 0.128, pvEstimate90: 2.5599, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T15:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.1594, pvEstimate10: 0.0716, pvEstimate90: 1.6839, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T15:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.0496, pvEstimate10: 0.0248, pvEstimate90: 0.6277, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T16:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0.0028, pvEstimate10: 0.0028, pvEstimate90: 0.0055, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T16:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0, pvEstimate10: 0, pvEstimate90: 0, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T17:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0, pvEstimate10: 0, pvEstimate90: 0, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T17:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0, pvEstimate10: 0, pvEstimate90: 0, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T18:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0, pvEstimate10: 0, pvEstimate90: 0, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T18:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0, pvEstimate10: 0, pvEstimate90: 0, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T19:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0, pvEstimate10: 0, pvEstimate90: 0, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T19:30:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0, pvEstimate10: 0, pvEstimate90: 0, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T20:00:00Z")!, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 0, pvEstimate10: 0, pvEstimate90: 0, periodEnd: ISO8601DateFormatter().date(from: "2023-11-14T20:30:00Z")!, period: "PT30M")
        ])
    }
}
