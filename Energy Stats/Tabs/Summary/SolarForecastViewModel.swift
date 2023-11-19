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

struct SolcastSolarForecastingConfigurationAdapter: SolcastSolarForecastingConfiguration {
    var resourceId: String?
    var apiKey: String?

    init(resourceId: String?, apiKey: String?) {
        self.resourceId = resourceId
        self.apiKey = apiKey
    }
}

typealias SolarForecastProviding = (SolcastSolarForecastingConfiguration) -> SolarForecasting

class SolarForecastViewModel: ObservableObject {
    @Published var today: [SolcastForecastResponse] = []
    @Published var tomorrow: [SolcastForecastResponse] = []
    @Published var state: LoadState = .inactive
    private var cancellable: AnyCancellable?
    private let configManager: ConfigManaging
    private let solarForecastProvider: (SolcastSolarForecastingConfiguration) -> SolarForecasting
    private(set) var service: SolarForecasting?

    init(configManager: ConfigManaging, appSettingsPublisher: LatestAppPublisher, solarForecastProvider: @escaping SolarForecastProviding) {
        self.configManager = configManager
        self.solarForecastProvider = solarForecastProvider
        self.cancellable = appSettingsPublisher.sink { [weak self] appSettings in
            let config = SolcastSolarForecastingConfigurationAdapter(resourceId: appSettings.solcastResourceId, apiKey: appSettings.solcastApiKey)
            self?.service = solarForecastProvider(config)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func load() {
        guard let service else { return }
        guard state == .inactive else { return }

        let today = Calendar.current.startOfDay(for: Date())
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return }

        state = .active("Loading...")

        Task {
            do {
                let data = try await service.fetchForecast().forecasts

                Task { @MainActor in
                    self.today = data.filter { $0.period_end.isSame(as: today) }
                    self.tomorrow = data.filter { $0.period_end.isSame(as: tomorrow) }
                    self.state = .inactive
                }
            } catch {
                print(error)
            }
        }
    }

    @objc
    func didBecomeActiveNotification() {
        load()
    }
}
