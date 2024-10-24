//
//  SolcastCache.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 15/11/2023.
//

import Foundation

public protocol SolcastCaching {
    func fetchSites(apiKey: String) async throws -> SolcastSiteResponseList
    func fetchForecast(for site: SolcastSite, apiKey: String, ignoreCache: Bool) async throws -> SolcastForecastList
}

public struct SolcastForecastList {
    public var tooManyRequests: Bool
    public let forecasts: [SolcastForecastResponse]

    public init(tooManyRequests: Bool, forecasts: [SolcastForecastResponse]) {
        self.tooManyRequests = tooManyRequests
        self.forecasts = forecasts
    }
}

public class SolcastCache: SolcastCaching {
    private let service: SolcastFetching
    private let today: () -> Date
    private let fileManager: FileManaging

    public init(service makeService: () -> SolcastFetching,
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

    public func fetchForecast(for site: SolcastSite, apiKey: String, ignoreCache: Bool) async throws -> SolcastForecastList {
        guard let fileURL = makeFileURL(for: site) else {
            throw ConfigMissingError()
        }

        let eightHours: Double = 28_800
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let retrievedData = try? Data(contentsOf: fileURL),
           let cachedDataModel = try? decoder.decode(SolcastForecastResponseList.self, from: retrievedData)
        {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            if let modificationDate = attributes[.modificationDate] as? Date,
               (today().timeIntervalSince(modificationDate) > eightHours) || ignoreCache
            {
                return try await fetchAndStore(for: site, apiKey: apiKey, merging: cachedDataModel, fileURL: fileURL)
            } else {
                return SolcastForecastList(tooManyRequests: false, forecasts: cachedDataModel.forecasts)
            }
        } else {
            return try await fetchAndStore(for: site, apiKey: apiKey, fileURL: fileURL)
        }
    }

    private func fetchAndStore(for site: SolcastSite, apiKey: String, merging previous: SolcastForecastResponseList? = nil, fileURL: URL) async throws -> SolcastForecastList {
        var latest: [SolcastForecastResponse]
        var tooManyRequests = false

        do {
            latest = try await service.fetchForecast(for: site, apiKey: apiKey).forecasts
        } catch (NetworkError.tryLater) {
            latest = []
            tooManyRequests = true
        }

        let previous = previous?.forecasts ?? []
        let todayStart = Calendar.current.startOfDay(for: today())

        var merged = previous.map { p in
            if let indexOfLatestForecastPeriod = latest.firstIndex(where: { $0.periodEnd == p.periodEnd }) {
                return latest.remove(at: indexOfLatestForecastPeriod)
            }
            return p
        }

        merged.append(contentsOf: latest)
        merged = merged.filter { $0.periodEnd >= todayStart }

        if merged.isEmpty {
            try? fileManager.removeItem(at: fileURL)
        } else {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let result = SolcastForecastResponseList(forecasts: merged)
            let data = try encoder.encode(result)
            try data.write(to: fileURL)
        }

        return SolcastForecastList(tooManyRequests: tooManyRequests, forecasts: merged)
    }

    private func makeFileURL(for site: SolcastSite) -> URL? {
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("solcast-\(site.resourceId).json")
    }
}

extension FileManager: FileManaging {}

public protocol FileManaging {
    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any]
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func removeItem(at url: URL) throws
}
