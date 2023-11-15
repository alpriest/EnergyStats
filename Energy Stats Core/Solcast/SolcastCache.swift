//
//  SolcastCache.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 15/11/2023.
//

import Foundation

public class SolcastCache: SolarForecasting {
    private let config: SolcastSolarForecastingConfiguration
    private let service: SolarForecasting

    public init(config: SolcastSolarForecastingConfiguration) {
        self.config = config
        service = Solcast(config: config)
    }

    public func fetchForecast() async throws -> SolcastForecastResponseList {
        let fileManager = FileManager.default
        let threeHours: Double = 10_800
        let decoder = JSONDecoder()

        if let retrievedData = try? Data(contentsOf: fileURL),
           let cachedDataModel = try? decoder.decode(SolcastForecastResponseList.self, from: retrievedData)
        {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            if let modificationDate = attributes[.modificationDate] as? Date,
               Date().timeIntervalSince(modificationDate) > threeHours
            {
                return try await fetchAndStore(merging: cachedDataModel)
            } else {
                return cachedDataModel
            }
        } else {
            return try await fetchAndStore()
        }
    }

    private func fetchAndStore(merging previous: SolcastForecastResponseList? = nil) async throws -> SolcastForecastResponseList {
        var latest = try await service.fetchForecast().forecasts
        let previous = previous?.forecasts ?? []
        let todayStart = Calendar.current.startOfDay(for: Date())

        var merged = previous.map { p in
            if let indexOfLatestForecastPeriod = latest.firstIndex(where: { $0.period_end == p.period_end }) {
                return latest.remove(at: indexOfLatestForecastPeriod)
            }
            return p
        }

        merged.append(contentsOf: latest)
        merged = merged.filter { $0.period_end >= todayStart }

        let encoder = JSONEncoder()
        let data = try encoder.encode(merged)
        try data.write(to: fileURL)

        return SolcastForecastResponseList(forecasts: merged)
    }

    private var fileURL: URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("solcast.json")
    }
}
