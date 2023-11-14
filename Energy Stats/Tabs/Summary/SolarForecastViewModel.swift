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
        guard state == .inactive else { return }
        guard let config = SolcastSolarForecastingConfigurationAdapter(configManager: configManager) else { return }

        state = .active("Loading...")

        let service = SolcastCache(config: config)

        Task {
            let data = try await service.fetchForecast().forecasts // TODO: CACHE
            let today = Date()
            let tomorrow = Date().addingTimeInterval(86400)

            Task { @MainActor in
                self.today = data.filter { $0.period_end.isSame(as: today) }
                self.tomorrow = data.filter { $0.period_end.isSame(as: tomorrow) }
                self.state = .inactive
            }
        }
    }
}

class SolcastCache: SolarForecasting {
    private let config: SolcastSolarForecastingConfiguration
    private let service: SolarForecasting

    init(config: SolcastSolarForecastingConfiguration) {
        self.config = config
        service = Solcast(config: config)
    }

    func fetchForecast() async throws -> SolcastForecastResponseList {
        let fileManager = FileManager.default
        let threeHours: Double = 10_800

        if let retrievedData = try? Data(contentsOf: fileURL) {
            let decoder = JSONDecoder()
            let cachedDataModel = try decoder.decode(SolcastForecastResponseList.self, from: retrievedData)

            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            if let modificationDate = attributes[.modificationDate] as? Date,
               Date().timeIntervalSince(modificationDate) > threeHours {
                return try await fetchAndStore()
            } else {
                return cachedDataModel
            }
        } else {
            return try await fetchAndStore()
        }
    }

    private func fetchAndStore() async throws -> SolcastForecastResponseList {
        let fetched = try await service.fetchForecast()
        let encoder = JSONEncoder()
        let data = try encoder.encode(fetched)
        try data.write(to: fileURL)

        return fetched
    }

    private var fileURL: URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("solcast.json")
    }
}
