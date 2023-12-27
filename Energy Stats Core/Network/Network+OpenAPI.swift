//
//  Network+OpenAPI.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 23/12/2023.
//

import Foundation

extension URL {
    static var getOpenRealData = URL(string: "https://www.foxesscloud.com/op/v0/device/real/query")!
    static var getOpenHistoryData = URL(string: "https://www.foxesscloud.com/op/v0/device/history/query")!
}

public extension Network {
    func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        var request = URLRequest(url: URL.getOpenRealData)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(OpenQueryRequest(deviceSN: deviceSN, variables: variables))

        do {
            let result: ([OpenQueryResponse], Data) = try await fetch(request)
            if let group = result.0.first(where: { $0.deviceSN == deviceSN }) {
                return group
            } else {
                throw NetworkError.missingData
            }
        } catch {
            print(error)
            throw error
        }
    }

    func openapi_fetchHistory(deviceSN: String, variables: [String]) async throws -> OpenHistoryResponse {
        var request = URLRequest(url: URL.getOpenHistoryData)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(OpenHistoryRequest(deviceSN: deviceSN, variables: variables))

        do {
            let result: ([OpenHistoryResponse], Data) = try await fetch(request)
            if let group = result.0.first(where: { $0.deviceSN == deviceSN }) {
                return group
            } else {
                throw NetworkError.missingData
            }
        } catch {
            print(error)
            throw error
        }
    }
}
