//
//  SolcastCache.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 15/11/2023.
//

import Foundation

public class SolcastCache: SolarForecasting {
    private let service: SolarForecasting
    private let today: () -> Date
    private let fileManager: FileManaging

    public init(service makeService: () -> SolarForecasting,
                today: @escaping () -> Date = { Date() },
                fileManager: FileManaging = FileManager.default)
    {
        self.service = makeService()
        self.today = today
        self.fileManager = fileManager
    }

    public func fetchSites(apiKey: String) async throws -> SolcastSiteResponseList {
        try await service.fetchSites(apiKey: apiKey)
    }

    public func fetchForecast(for site: SolcastSettings.Site, apiKey: String) async throws -> SolcastForecastResponseList {
        guard let fileURL = makeFileURL(for: site) else {
            throw ConfigMissingError()
        }

        let twelveHours: Double = 43_200
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let retrievedData = try? Data(contentsOf: fileURL),
           let cachedDataModel = try? decoder.decode(SolcastForecastResponseList.self, from: retrievedData)
        {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            if let modificationDate = attributes[.modificationDate] as? Date,
               today().timeIntervalSince(modificationDate) > twelveHours
            {
                return try await fetchAndStore(for: site, apiKey: apiKey, merging: cachedDataModel, fileURL: fileURL)
            } else {
                return cachedDataModel
            }
        } else {
            return try await fetchAndStore(for: site, apiKey: apiKey, fileURL: fileURL)
        }
    }

    private func fetchAndStore(for site: SolcastSettings.Site, apiKey: String, merging previous: SolcastForecastResponseList? = nil, fileURL: URL) async throws -> SolcastForecastResponseList {
        var latest = try await service.fetchForecast(for: site, apiKey: apiKey).forecasts
        let previous = previous?.forecasts ?? []
        let todayStart = Calendar.current.startOfDay(for: today())

        var merged = previous.map { p in
            if let indexOfLatestForecastPeriod = latest.firstIndex(where: { $0.period_end == p.period_end }) {
                return latest.remove(at: indexOfLatestForecastPeriod)
            }
            return p
        }

        merged.append(contentsOf: latest)
        merged = merged.filter { $0.period_end >= todayStart }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let result = SolcastForecastResponseList(forecasts: merged)
        let data = try encoder.encode(result)
        try data.write(to: fileURL)

        return result
    }

    private func makeFileURL(for site: SolcastSettings.Site) -> URL? {
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("solcast-\(site.resourceId).json")
    }
}

extension FileManager: FileManaging {}

public protocol FileManaging {
    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any]
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
}
