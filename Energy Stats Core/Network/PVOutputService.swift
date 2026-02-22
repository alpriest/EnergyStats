//
//  PVOutputService.swift
//  Energy Stats
//
//  Created by Alistair Priest on 17/02/2026.
//

import Foundation

public struct PVOutputRecord: Sendable {
    public let outputDate: Date
    public let generated: Double
    public let exported: Double

    public init(outputDate: Date, generated: Double, exported: Double) {
        self.outputDate = outputDate
        self.generated = generated
        self.exported = exported
    }
}

public struct PVOutputConfig: Codable {
    public let apiKey: String
    public let systemId: String
    
    public init(apiKey: String, systemId: String) {
        self.apiKey = apiKey
        self.systemId = systemId
    }
}

public protocol PVOutputServicing {
    func post(output: PVOutputRecord) async throws
    func verify(credentials: PVOutputConfig) async -> Bool
}

public final class PVOutputService: PVOutputServicing {
    private let urlSession: URLSessionProtocol
    private let configManager: ConfigManaging

    public init(urlSession: URLSessionProtocol = URLSession.shared, configManager: ConfigManaging) {
        self.urlSession = urlSession
        self.configManager = configManager
    }

    public func post(output: PVOutputRecord) async throws {
        guard let url = URL(string: "https://pvoutput.org/service/r2/addoutput.jsp") else {
            throw NetworkError.invalidConfiguration("Invalid PVOutput endpoint")
        }
        guard let config = configManager.pvOutputConfig else {
            throw ConfigMissingError()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.httpBody = formBody(for: output)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(UserAgent.description(), forHTTPHeaderField: "User-Agent")
        request.setValue(config.apiKey, forHTTPHeaderField: "X-Pvoutput-Apikey")
        request.setValue(config.systemId, forHTTPHeaderField: "X-Pvoutput-SystemId")

        do {
            let (data, response) = try await urlSession.data(for: request, delegate: nil)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown("Invalid response type")
            }

            let statusCode = httpResponse.statusCode
            if statusCode == 401 || statusCode == 403 {
                throw NetworkError.badCredentials
            }

            if statusCode == 429 {
                throw NetworkError.tryLater
            }

            guard 200 ... 299 ~= statusCode else {
                let message = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                if statusCode == 400 {
                    throw NetworkError.invalidConfiguration(message ?? "Bad request")
                }
                throw NetworkError.invalidResponse(request.url, statusCode)
            }
        } catch let error as NSError {
            if error.domain == NSURLErrorDomain, error.code == URLError.notConnectedToInternet.rawValue {
                throw NetworkError.offline
            } else if error.domain == NSURLErrorDomain, error.code == URLError.timedOut.rawValue {
                throw NetworkError.timedOut
            } else {
                throw error
            }
        }
    }
    
    public func verify(credentials config: PVOutputConfig) async -> Bool {
        guard let url = URL(string: "https://pvoutput.org/service/r2/getstatus.jsp") else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(UserAgent.description(), forHTTPHeaderField: "User-Agent")
        request.setValue(config.apiKey, forHTTPHeaderField: "X-Pvoutput-Apikey")
        request.setValue(config.systemId, forHTTPHeaderField: "X-Pvoutput-SystemId")
        
        do {
            let (_, response) = try await urlSession.data(for: request, delegate: nil)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown("Invalid response type")
            }

            let statusCode = httpResponse.statusCode
            if statusCode == 401 {
                return false
            }
            return true
        } catch {
            return false
        }
    }

    private func formBody(for output: PVOutputRecord) -> Data {
        let items = [
            URLQueryItem(name: "d", value: Self.dateFormatter.string(from: output.outputDate)),
            URLQueryItem(name: "g", value: String(output.generated)),
            URLQueryItem(name: "e", value: String(output.exported))
        ]
        var components = URLComponents()
        components.queryItems = items
        let query = components.percentEncodedQuery ?? ""
        return Data(query.utf8)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    public static func preview() -> PVOutputService {
        PVOutputService(configManager: ConfigManager.preview())
    }
}
