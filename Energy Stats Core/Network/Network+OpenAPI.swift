//
//  Network+OpenAPI.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 23/12/2023.
//

import Foundation

extension URL {
    static var getRealData = URL(string: "https://www.foxesscloud.com/op/v0/device/real/query")!
}

public extension Network {
    func fetchRealData(deviceSN: String, variables: [String]) async throws -> [RealQueryResponse] {
        var request = URLRequest(url: URL.getRealData)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(RealQueryRequest(deviceSN: deviceSN, variables: variables))

        do {
            let result: ([RealQueryResponse], Data) = try await fetch(request)
            return result.0
        } catch {
            print(error)
            throw error
        }
    }
}
