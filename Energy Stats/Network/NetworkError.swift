//
//  NetworkError.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/04/2023.
//

import Foundation

enum NetworkError: LocalizedError, CustomStringConvertible {
    case invalidResponse(_ url: URL?, _ responseCode: Int?)
    case invalidConfiguration(_ reason: String)
    case badCredentials
    case unknown
    case invalidToken
    case tryLater
    case offline

    var description: String {
        let builder = PartBuilder()

        switch self {
        case .invalidResponse(let url, let responseCode):
            builder.append("Network Error")
            builder.append("Could not fetch from", url)
            builder.append("Response code", responseCode)
        case .invalidConfiguration(let reason):
            builder.append("Invalid configuration", reason)
        case .badCredentials:
            builder.append("Bad credentials")
        case .unknown:
            builder.append("Unknown network error")
        case .invalidToken:
            builder.append("Invalid token. Please logout and login again.")
        case .tryLater:
            builder.append("You've hit the server rate limit. Please try later.")
        case .offline:
            builder.append("Servers are offline")
        }

        return builder.formatted()
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

