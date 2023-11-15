//
//  SolarForecastViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 14/11/2023.
//

import Combine
import Energy_Stats_Core
import Foundation

private struct SolcastSolarForecastingConfigurationAdapter: SolcastSolarForecastingConfiguration {
    var resourceId: String
    var apiKey: String

    init?(configManager: SolcastConfigManaging) {
        guard let resourceId = configManager.solcastResourceId,
              let apiKey = configManager.solcastApiKey else { return nil }

        self.resourceId = resourceId
        self.apiKey = apiKey
    }
}

class SolarForecastViewModel: ObservableObject {
    @Published var today: [SolcastForecastResponse] = []
    @Published var tomorrow: [SolcastForecastResponse] = []
    @Published var state: LoadState = .inactive
    @Published var hasConfig: Bool = false
    private var cancellable: AnyCancellable?
    private let configManager: ConfigManaging

    init(configManager: ConfigManaging, appTheme: LatestAppTheme) {
        self.configManager = configManager
        cancellable = appTheme.sink { [weak self] theme in
            self?.hasConfig = theme.solcastApiKey != nil && theme.solcastResourceId != nil
        }
    }

    func load() {
        guard state == .inactive,
              let config = SolcastSolarForecastingConfigurationAdapter(configManager: configManager) else { return }

        let today = Calendar.current.startOfDay(for: Date())
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return }

        state = .active("Loading...")

        let service = SolcastCache(config: config)

        Task {
            let data = try await service.fetchForecast().forecasts

            Task { @MainActor in
                self.today = data.filter { $0.period_end.isSame(as: today) }
                self.tomorrow = data.filter { $0.period_end.isSame(as: tomorrow) }
                self.state = .inactive
            }
        }
    }
}
