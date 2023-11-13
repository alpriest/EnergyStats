//
//  API.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 13/11/2023.
//

import Foundation

public protocol SolarForecasting {
    func fetchForecast() async throws -> SolcastForecastResponseList
}

public protocol SolcastSolarForecastingConfiguration {
    var resourceId: String { get }
    var apiKey: String { get }
}

private extension URL {
    static var rooftopSites = "https://api.solcast.com.au/rooftop_sites/{resource_id}/forecasts"
}

public class Solcast: SolarForecasting {
    private let config: SolcastSolarForecastingConfiguration

    public init(config: SolcastSolarForecastingConfiguration) {
        self.config = config
    }

    public func fetchForecast() async throws -> SolcastForecastResponseList {
        let url = URL(string: URL.rooftopSites.replacingOccurrences(of: "{resource_id}", with: config.resourceId))!
        let request = append(queryItems: [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "API_KEY", value: config.apiKey)
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

            let networkResponse: T = try JSONDecoder().decode(T.self, from: data)
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
