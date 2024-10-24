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

class SolarForecastViewModel: ObservableObject, HasLoadState {
    @Published var data: [SolarForecastViewData] = []
    @Published var state: LoadState = .inactive
    @Published var tooManyRequests: Bool = false
    @Published var hasSites: Bool = false
    @Published var canRefresh = true
    private var privateState: LoadState = .inactive {
        didSet {
            Task {
                await setState(privateState)
            }
        }
    }

    private var cancellable: AnyCancellable?
    private var configManager: ConfigManaging
    private let solarForecastProvider: () -> SolcastCaching
    private var settings: AppSettings { didSet {
        Task { @MainActor in
            hasSites = !settings.solcastSettings.sites.isEmpty
        }
    }}

    private struct SolcastFetchError: Error {
        let site: SolcastSite
        let innerError: Error
    }

    init(configManager: ConfigManaging, appSettingsPublisher: LatestAppSettingsPublisher, solarForecastProvider: @escaping SolarForecastProviding) {
        self.configManager = configManager
        self.solarForecastProvider = solarForecastProvider
        self.settings = appSettingsPublisher.value
        self.cancellable = appSettingsPublisher.assign(to: \.settings, on: self)
    }

    func load(ignoreCache: Bool = false) {
        updateCanRefresh(lastRefreshedAt: configManager.lastSolcastRefresh)
        guard privateState == .inactive else { return }
        guard settings.solcastSettings.sites.any else { return }
        guard let apiKey = settings.solcastSettings.apiKey else { return }

        let service = solarForecastProvider()
        let today = Calendar.current.startOfDay(for: Date())
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return }

        Task { @MainActor in
            guard privateState == .inactive else { return }
            privateState = .active("Loading")

            do {
                data = try await settings.solcastSettings.sites.asyncMap { site in
                    let data = try await service.fetchForecast(for: site, apiKey: apiKey, ignoreCache: ignoreCache)
                    let forecasts = data.forecasts
                    self.tooManyRequests = data.tooManyRequests
                    let todayData = forecasts.filter { $0.periodEnd.isSame(as: today) }
                    let tomorrowData = forecasts.filter { $0.periodEnd.isSame(as: tomorrow) }

                    return SolarForecastViewData(
                        error: nil,
                        today: todayData,
                        todayTotal: total(forecasts: todayData),
                        tomorrow: tomorrowData,
                        tomorrowTotal: total(forecasts: tomorrowData),
                        name: site.name,
                        resourceId: site.resourceId
                    )
                }.filter { $0.today.count > 0 || $0.tomorrow.count > 0 }

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
        guard let lastSolcastRefresh = configManager.lastSolcastRefresh else {
            load(ignoreCache: true)
            configManager.lastSolcastRefresh = .now
            return
        }

        configManager.lastSolcastRefresh = .now
        updateCanRefresh(lastRefreshedAt: configManager.lastSolcastRefresh)
    }

    private func updateCanRefresh(lastRefreshedAt date: Date?) {
        guard let lastSolcastRefresh = date else { return }

        let oneHour: Double = 3_600
        if Date.now.timeIntervalSince(lastSolcastRefresh) > oneHour {
            load(ignoreCache: true)
        } else {
            canRefresh = false
        }
    }

    @objc
    func didBecomeActiveNotification() {
        load()
    }

    func total(forecasts: [SolcastForecastResponse]) -> Double {
        let totalPVOutput = forecasts.reduce(0.0) { total, forecast in
            let periodHours = convertPeriodToHours(period: forecast.period)
            return total + (forecast.pvEstimate * periodHours)
        }

        return totalPVOutput
    }

    func convertPeriodToHours(period: String) -> Double {
        // Extract the numeric value from the period string (assuming format "PT30M")
        if let range = period.range(of: #"(\d+)"#, options: .regularExpression),
           let periodMinutes = Double(period[range])
        {
            return periodMinutes / 60.0 // Convert minutes to hours
        }
        return 0.0
    }
}
