//
//  API.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 13/11/2023.
//

import Foundation

public protocol SolarForecasting {
    func fetchForecast() async throws -> SolcastForecastResponseList
    var hasValidConfig: Bool { get }
}

public protocol SolcastSolarForecastingConfiguration {
    var resourceId: String? { get }
    var apiKey: String? { get }

    func credentials() -> (resourceId: String, apiKey: String)?
}

public extension SolcastSolarForecastingConfiguration {
    func credentials() -> (resourceId: String, apiKey: String)? {
        guard let resourceId, let apiKey else { return nil }

        return (resourceId, apiKey)
    }
}

private extension URL {
    static var rooftopSites = "https://api.solcast.com.au/rooftop_sites/{resource_id}/forecasts"
}

public struct ConfigMissingError: Error {}

public class Solcast: SolarForecasting {
    private let config: SolcastSolarForecastingConfiguration

    public init(config: SolcastSolarForecastingConfiguration) {
        self.config = config
    }

    public var hasValidConfig: Bool {
        config.apiKey != nil && config.resourceId != nil
    }

    public func fetchForecast() async throws -> SolcastForecastResponseList {
        guard let (resourceId, apiKey) = config.credentials() else {
            throw ConfigMissingError()
        }

        let url = URL(string: URL.rooftopSites.replacingOccurrences(of: "{resource_id}", with: resourceId))!
        let request = append(queryItems: [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "API_KEY", value: apiKey)
        ], to: url)

        do {
            return try await fetch(request)
        } catch let error {
            print(error)
            return SolcastForecastResponseList(forecasts: [])
        }
    }

    func fetch<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                throw NetworkError.unknown("", "Invalid response type")
            }

            guard 200 ... 300 ~= statusCode else { throw NetworkError.invalidResponse(request.url, statusCode) }

            let decoder = JSONDecoder.solcast()
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
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = formatter.date(from: dateString) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
            }
        })
        return decoder
    }
}

public class DemoSolcast: SolarForecasting {
    public init(config: SolcastSolarForecastingConfiguration) {}

    public func fetchForecast() async throws -> SolcastForecastResponseList {
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
                period_end: date ?? forecast.period_end
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
