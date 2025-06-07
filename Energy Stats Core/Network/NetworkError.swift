//
//  NetworkError.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/04/2023.
//

import Foundation
import SwiftUICore

public enum NetworkError: LocalizedError, CustomStringConvertible, Equatable {
    case invalidResponse(_ url: URL?, _ responseCode: Int?)
    case invalidConfiguration(_ reason: String)
    case badCredentials
    case foxServerError(_ errNo: Int, _ message: String)
    case invalidToken
    case tryLater
    case offline
    case timedOut
    case maintenanceMode
    case missingData
    case unknown(_ message: String)
    case requestRequiresSignature
    case apiRequestLimitExhausted

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
            builder.append("Bad credentials")
        case .foxServerError(let code, let message):
            builder.append(String("Fox OpenAPI servers returned error code: ") + String("\(code) \(message)"))
        case .invalidToken:
            builder.append("Invalid token. Please logout and login again.")
        case .tryLater:
            builder.append("You've hit the server rate limit. Please try later.")
        case .offline:
            builder.append("You appear to be offline. Please check your connection.")
        case .maintenanceMode:
            builder.append("Fox servers are offline. Please try later.")
        case .missingData:
            builder.append("No data was returned")
        case .requestRequiresSignature:
            builder.append("Fox no longer permits these requests")
        case .timedOut:
            builder.append("Request timed out")
        case .unknown(let message):
            builder.append(message)
        case .apiRequestLimitExhausted:
            builder.append("You have no more OpenAPI requests left. If this is unexpected please check the 'number of calls per day' on the API Management page of https://www.foxesscloud.com")
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
