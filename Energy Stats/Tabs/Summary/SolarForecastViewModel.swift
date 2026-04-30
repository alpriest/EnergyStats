//
//  SolarForecastViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 14/11/2023.
//

import Combine
import Energy_Stats_Core
import Foundation
import UIKit

typealias SolarForecastProviding = () -> SolcastCaching

struct SolarForecastViewData: Identifiable {
    let id: String = UUID().uuidString

    let error: String?
    let today: [SolcastForecastResponse]
    let todayTotal: Double
    let tomorrow: [SolcastForecastResponse]
    let tomorrowTotal: Double
    let name: String?
    let resourceId: String
}

enum SolarForecastPeriod {
    case yesterday
    case lastWeek
}

struct PercentageSolarForecastAchievedData {
    let totalSolarForecast: Double
    let totalSolarAchieved: Double
    let percentageSolarForecastAchieved: Double
    let description: String
    let forecastCompleteness: Double
}

private struct SolarForecastTotalData {
    let total: Double
    let percentageTimePeriodsAvailable: Double
}

class SolarForecastViewModel: ObservableObject, HasLoadState {
    @Published var lastFetched: Date?
    @Published var data: [SolarForecastViewData] = []
    @Published var solarForecastAchievedData: PercentageSolarForecastAchievedData? = nil
    @Published var state: LoadState = .inactive
    @Published var tooManyRequests: Bool = false
    @Published var hasSites: Bool = false
    @Published var canRefresh = true
    @Published var period: SolarForecastPeriod = .yesterday
    private var privateState: LoadState = .inactive {
        didSet {
            Task {
                await setState(privateState)
            }
        }
    }

    private var cancellable: AnyCancellable?
    let configManager: ConfigManaging
    let solarForecastProvider: () -> SolcastCaching
    let networking: Networking
    private var settings: AppSettings { didSet {
        Task { @MainActor in
            hasSites = !settings.solcastSettings.sites.isEmpty
        }
    }}

    private struct SolcastFetchError: Error {
        let site: SolcastSite
        let innerError: Error
    }

    init(configManager: ConfigManaging, solarForecastProvider: @escaping SolarForecastProviding, networking: Networking) {
        self.configManager = configManager
        self.networking = networking
        self.solarForecastProvider = solarForecastProvider
        self.settings = configManager.currentAppSettings
        self.cancellable = configManager.appSettingsPublisher.assign(to: \.settings, on: self)
    }

    func load(ignoreCache: Bool = false) {
        updateCanRefresh(lastRefreshedAt: configManager.lastSolcastRefresh)
        guard privateState == .inactive else { return }
        guard settings.solcastSettings.sites.any else { return }
        guard let apiKey = settings.solcastSettings.apiKey else { return }

        let service = solarForecastProvider()
        let today = Calendar.current.startOfDay(for: Date())
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return }
        self.lastFetched = configManager.lastSolcastRefresh

        Task { @MainActor in
            guard privateState == .inactive else { return }
            privateState = .active(.loading)

            do {
                var allForecasts: [SolcastForecastResponse] = []

                data = try await settings.solcastSettings.sites.asyncMap { site in
                    let data = try await service.fetchForecast(for: site, apiKey: apiKey, ignoreCache: ignoreCache)
                    let forecasts = data.forecasts
                    allForecasts += forecasts
                    self.tooManyRequests = data.tooManyRequests
                    let todayData = forecasts.filter { $0.periodEnd.isSame(as: today) }
                    let tomorrowData = forecasts.filter { $0.periodEnd.isSame(as: tomorrow) }
                    self.lastFetched = configManager.lastSolcastRefresh

                    return SolarForecastViewData(
                        error: nil,
                        today: todayData,
                        todayTotal: todayData.total(),
                        tomorrow: tomorrowData,
                        tomorrowTotal: tomorrowData.total(),
                        name: site.name,
                        resourceId: site.resourceId
                    )
                }.filter { $0.today.count > 0 || $0.tomorrow.count > 0 }

                solarForecastAchievedData = try await calculateSolarForecastAchieved(forecasts: allForecasts, siteCount: settings.solcastSettings.sites.count)

                privateState = .inactive
            } catch NetworkError.tryLater {
                privateState = .error(nil, "You have exceeded your free daily limit.")
                data = []
            } catch {
                privateState = .error(error, error.localizedDescription)
                data = []
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func refetchSolcast() {
        load(ignoreCache: true)
    }

    private func updateCanRefresh(lastRefreshedAt date: Date?) {
        guard let lastSolcastRefresh = date else {
            canRefresh = true
            return
        }

        let oneHour: Double = 3_600
        canRefresh = Date.now.timeIntervalSince(lastSolcastRefresh) > oneHour
    }

    @objc
    func didBecomeActiveNotification() {
        load()
    }

    func togglePeriod() {
        period = period == .lastWeek ? .yesterday : .lastWeek
        load()
    }

    private func calculateSolarForecastAchieved(forecasts: [SolcastForecastResponse], siteCount: Int) async throws -> PercentageSolarForecastAchievedData? {
        guard let (startDate, endDate) = dates() else { return nil }

        let totalSolarAchieved = try await calculateSolarGenerated(from: startDate, to: endDate)

        let solarForecastTotalData = calculateSolarForecastTotal(
            from: startDate,
            to: endDate,
            forecasts: forecasts,
            siteCount: siteCount
        )

        let totalSolarForecast = solarForecastTotalData.total
        let percentageSolarForecastAchieved: Double = totalSolarForecast > 0 ? (totalSolarAchieved / totalSolarForecast) : 0
        let coverage = solarForecastTotalData.percentageTimePeriodsAvailable

        let description = String(
            key: .solarVsForecastFooter,
            bundle: .main,
            arguments:
            coverage.percent(maximumFractionDigits: 0),
            percentageSolarForecastAchieved.percent(maximumFractionDigits: 0)
        )

        return PercentageSolarForecastAchievedData(
            totalSolarForecast: totalSolarForecast,
            totalSolarAchieved: totalSolarAchieved,
            percentageSolarForecastAchieved: percentageSolarForecastAchieved,
            description: description,
            forecastCompleteness: coverage
        )
    }

    private func dates() -> (Date, Date)? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate: Date
        let endDate: Date

        switch period {
        case .yesterday:
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return nil }
            startDate = yesterday
            endDate = yesterday

        case .lastWeek:
            guard let firstDay = calendar.date(byAdding: .day, value: -6, to: today) else { return nil }
            startDate = firstDay
            endDate = today
        }

        return (startDate, endDate)
    }

    private func calculateSolarGenerated(from startDate: Date, to endDate: Date) async throws -> Double {
        guard let deviceSN = configManager.selectedDeviceSN else { return 0 }

        let calendar = Calendar.current

        let days = stride(from: startDate, through: endDate, by: 60 * 60 * 24).map { calendar.startOfDay(for: $0) }

        let monthStartDates = Array(Set(days.compactMap {
            calendar.date(from: calendar.dateComponents([.year, .month], from: $0))
        }))

        var totalSolarAchieved = 0.0

        for monthStartDate in monthStartDates {
            if let rawData = try await networking.fetchReport(
                deviceSN: deviceSN,
                variables: [.pvEnergyTotal],
                queryDate: QueryDate(from: monthStartDate),
                reportType: .month
            )[safe: 0] {
                for day in days where calendar.isDate(day, equalTo: monthStartDate, toGranularity: .month) {
                    let dayIndex = calendar.component(.day, from: day) - 1

                    guard rawData.values.count > dayIndex else { continue }

                    let value = rawData.values[dayIndex].value

                    totalSolarAchieved += value
                }
            }
        }

        return totalSolarAchieved
    }

    private func calculateSolarForecastTotal(from startDate: Date, to endDate: Date, forecasts: [SolcastForecastResponse], siteCount: Int) -> SolarForecastTotalData {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: startDate)
        let endDate = calendar.startOfDay(for: endDate)

        let filtered = forecasts.filter { forecast in
            let forecastDay = calendar.startOfDay(for: forecast.periodEnd)
            return forecastDay >= startDate && forecastDay <= endDate
        }

        let forecastsCount = filtered.count / siteCount
        let total = filtered.total()
        let expectedPeriodCount = expectedThirtyMinutePeriodCount(from: startDate, to: endDate)
        let percentageTimePeriodsAvailable = expectedPeriodCount > 0 ? (Double(forecastsCount) / Double(expectedPeriodCount)) : 0

        return SolarForecastTotalData(
            total: total,
            percentageTimePeriodsAvailable: percentageTimePeriodsAvailable
        )
    }

    private func expectedThirtyMinutePeriodCount(from startDate: Date, to endDate: Date) -> Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day! + 1
        return days * 48
    }
}

extension Array where Element == SolcastForecastResponse {
    func total() -> Double {
        func convertPeriodToHours(period: String) -> Double {
            // Extract the numeric value from the period string (assuming format "PT30M")
            if let range = period.range(of: #"(\d+)"#, options: .regularExpression),
               let periodMinutes = Double(period[range])
            {
                return periodMinutes / 60.0 // Convert minutes to hours
            }
            return 0.0
        }

        return reduce(0.0) { total, forecast in
            let periodHours = convertPeriodToHours(period: forecast.period)
            return total + (forecast.pvEstimate * periodHours)
        }
    }
}
