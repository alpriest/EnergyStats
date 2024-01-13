//
//  NetworkError.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/04/2023.
//

import Foundation

public enum NetworkError: LocalizedError, CustomStringConvertible, Equatable {
    case invalidResponse(_ url: URL?, _ responseCode: Int?)
    case invalidConfiguration(_ reason: String)
    case badCredentials
    case foxServerError(_ errNo: Int, _ message: String)
    case invalidToken
    case tryLater
    case offline
    case maintenanceMode
    case missingData
    case unknown(_ message: String)
    case requestRequiresSignature

    public var description: String {
        let builder = PartBuilder()

        switch self {
        case .invalidResponse(let url, let responseCode):
            builder.append("Network Error")
            builder.append("Could not fetch from", url)
            builder.append("Response code", responseCode)
        case .invalidConfiguration(let reason):
            builder.append("Invalid configuration", reason)
        case .badCredentials:
            builder.append(String(localized: "Bad credentials"))
        case .foxServerError(let code, let message):
            builder.append(String("Code: \(code) \(message)"))
        case .invalidToken:
            builder.append(String(localized: "Invalid token. Please logout and login again."))
        case .tryLater:
            builder.append(String(localized: "You've hit the server rate limit. Please try later."))
        case .offline:
            builder.append(String(localized: "You appear to be offline. Please check your connection."))
        case .maintenanceMode:
            builder.append(String(localized: "Fox servers are offline. Please try later."))
        case .missingData:
            builder.append(String(localized: "No data was returned"))
        case .requestRequiresSignature:
            builder.append(String(localized: "Fox no longer permits these requests."))
        case .unknown(let message):
            builder.append(message)
        }

        return builder.formatted()
    }

    public var errorDescription: String? {
        description
    }

    private class PartBuilder {
        private var parts = [String]()

        func append(_ part: String) {
            parts.append(part)
        }

        func append<T>(_ prefix: String, _ part: T?) {
            guard let part = part else { return }

            parts.append("\(prefix) \(part)")
        }

        func formatted() -> String {
            parts.joined(separator: "\n\n")
        }
    }
}
