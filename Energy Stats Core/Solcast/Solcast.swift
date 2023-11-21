//
//  API.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 13/11/2023.
//

import Foundation

public protocol SolarForecasting {
    func fetchSites(apiKey: String) async throws -> SolcastSiteResponseList
    func fetchForecast(for site: SolcastSettings.Site, apiKey: String) async throws -> SolcastForecastResponseList
}

private extension URL {
    static var rooftopSites = "https://api.solcast.com.au/rooftop_sites"
    static var rooftopSitesForecast = "https://api.solcast.com.au/rooftop_sites/{resource_id}/forecasts"
}

public struct ConfigMissingError: Error {}

public class Solcast: SolarForecasting {
    public init() { }

    public func fetchSites(apiKey: String) async throws -> SolcastSiteResponseList {
        let url = URL(string: URL.rooftopSites)!
        let request = append(queryItems: [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "API_KEY", value: apiKey)
        ], to: url)

        do {
            return try await fetch(request)
        } catch {
            throw error
        }
    }

    public func fetchForecast(for site: SolcastSettings.Site, apiKey: String) async throws -> SolcastForecastResponseList {
        let url = URL(string: URL.rooftopSitesForecast.replacingOccurrences(of: "{resource_id}", with: site.resourceId))!
        let request = append(queryItems: [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "API_KEY", value: apiKey)
        ], to: url)

        do {
            return try await fetch(request)
        } catch {
            throw error
        }
    }

    func fetch<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                throw NetworkError.unknown("", "Invalid response type")
            }

            let decoder = JSONDecoder.solcast()

            if statusCode == 404 {
                let errorResponse = try decoder.decode(ErrorApiResponse.self, from: data)
                throw NetworkError.invalidConfiguration(errorResponse.responseStatus.message)
            }

            guard 200 ... 300 ~= statusCode else {
                throw NetworkError.invalidResponse(request.url, statusCode)
            }

            let networkResponse: T = try decoder.decode(T.self, from: data)
            return networkResponse
        } catch let error as NSError {
            if error.domain == NSURLErrorDomain, error.code == URLError.notConnectedToInternet.rawValue {
                throw NetworkError.offline
            } else {
                throw error
            }
        }
    }

    private func append(queryItems: [URLQueryItem], to url: URL) -> URLRequest {
        let request: URLRequest

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        request = URLRequest(url: components!.url!)

        return request
    }
}

extension JSONDecoder {
    static func solcast() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = formatter.date(from: dateString) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
            }
        }
        return decoder
    }
}

private struct ErrorApiResponse: Decodable {
    let responseStatus: ResponseStatus

    enum CodingKeys: String, CodingKey {
        case responseStatus = "response_status"
    }
}

private struct ResponseStatus: Decodable {
    let message: String
}


public class DemoSolcast: SolarForecasting {
    public init() {}

    public func fetchSites(apiKey: String) async throws -> SolcastSiteResponseList {
        SolcastSiteResponseList(sites: [
            SolcastSiteResponse(name: "Front", resourceId: "abc-123", capacity: 3.7, longitude: -0.2664026, latitude: 51.5287398, azimuth: 134, tilt: 45, lossFactor: 0.9),
            SolcastSiteResponse(name: "Back", resourceId: "abc-123", capacity: 4.1, longitude: -0.2664026, latitude: 51.5287398, azimuth: 226, tilt: 45, lossFactor: 0.9)
        ])
    }

    public func fetchForecast(for site: SolcastSettings.Site, apiKey: String) async throws -> SolcastForecastResponseList {
        let data = try data(filename: "solcast")
        let decoder = JSONDecoder.solcast()
        let result = try decoder.decode(SolcastForecastResponseList.self, from: data)
        let day1 = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 15))!
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        return SolcastForecastResponseList(forecasts: result.forecasts.map { forecast in
            let thenComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: forecast.period_end)

            let date: Date?
            if forecast.period_end.isSame(as: day1) {
                date = Calendar.current.date(bySettingHour: thenComponents.hour ?? 0, minute: thenComponents.minute ?? 0, second: thenComponents.second ?? 0, of: today)
            } else {
                date = Calendar.current.date(bySettingHour: thenComponents.hour ?? 0, minute: thenComponents.minute ?? 0, second: thenComponents.second ?? 0, of: tomorrow)
            }

            return SolcastForecastResponse(
                pv_estimate: forecast.pv_estimate,
                pv_estimate10: forecast.pv_estimate10,
                pv_estimate90: forecast.pv_estimate90,
                period_end: date ?? forecast.period_end,
                period: forecast.period
            )
        })
    }

    public var hasValidConfig: Bool { true }

    private func data(filename: String) throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: filename, withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }
}
