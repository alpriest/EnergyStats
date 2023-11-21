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

typealias SolarForecastProviding = () -> SolarForecasting

struct SolarForecastViewData: Identifiable {
    let id: String = UUID().uuidString

    let today: [SolcastForecastResponse]
    let todayTotal: Double
    let tomorrow: [SolcastForecastResponse]
    let tomorrowTotal: Double
    let name: String?
}

class SolarForecastViewModel: ObservableObject {
    @Published var data: [SolarForecastViewData] = []
    @Published var state: LoadState = .inactive
    @Published var hasSites: Bool = false
    private var cancellable: AnyCancellable?
    private let configManager: ConfigManaging
    private let solarForecastProvider: () -> SolarForecasting
    private var settings: AppSettings { didSet {
        hasSites = !settings.solcastSettings.sites.isEmpty
    }}

    init(configManager: ConfigManaging, appSettingsPublisher: LatestAppPublisher, solarForecastProvider: @escaping SolarForecastProviding) {
        self.configManager = configManager
        self.solarForecastProvider = solarForecastProvider
        self.settings = appSettingsPublisher.value
        self.cancellable = appSettingsPublisher.assign(to: \.settings, on: self)
    }

    func load() {
        guard state == .inactive else { return }
        guard settings.solcastSettings.sites.any() else { return }
        guard let apiKey = settings.solcastSettings.apiKey else { return }

        let service = solarForecastProvider()
        let today = Calendar.current.startOfDay(for: Date())
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return }

        state = .active("Loading...")

        Task { @MainActor in
            data = await settings.solcastSettings.sites
                .asyncMap { site in
                    do {
                        let data = try await service.fetchForecast(for: site, apiKey: apiKey).forecasts
                        let todayData = data.filter { $0.periodEnd.isSame(as: today) }
                        let tomorrowData = data.filter { $0.periodEnd.isSame(as: tomorrow) }

                        return SolarForecastViewData(
                            today: todayData,
                            todayTotal: total(forecasts: todayData),
                            tomorrow: tomorrowData,
                            tomorrowTotal: total(forecasts: tomorrowData),
                            name: site.name
                        )
                    } catch let error {
                        print("AWP", error)
                        return nil
                    }
                }
                .compactMap { $0 }

            self.state = .inactive
        }

        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
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
