//
//  NetworkCache.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 12/09/2023.
//

import Foundation

struct CachedItem {
    let cacheTime: Date
    let item: Codable

    init(_ item: Codable) {
        self.cacheTime = Date()
        self.item = item
    }

    func isFresherThan(interval: TimeInterval) -> Bool {
        abs(cacheTime.timeIntervalSinceNow) < interval
    }
}

public class NetworkCache: FoxESSNetworking {
    private let network: FoxESSNetworking
    private var cache: [String: CachedItem] = [:]
    private let shortCacheDurationInSeconds: TimeInterval = 5
    private let serialiserQueue = DispatchQueue(label: "networkcache.write.queue")

    public init(network: FoxESSNetworking) {
        self.network = network
    }

    public func fetchErrorMessages() async {
        await network.fetchErrorMessages()
    }

    // TODO
//    public func fetchVariables(deviceID: String) async throws -> [RawVariable] {
//        try await network.fetchVariables(deviceID: deviceID)
//    }

    public func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        let key = makeKey(base: #function, arguments: deviceSN, variables.joined(separator: "_"))

        if let item = cache[key], let cached = item.item as? OpenQueryResponse, item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await network.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    public func openapi_fetchHistory(deviceSN: String, variables: [String]) async throws -> OpenHistoryResponse {
        try await network.openapi_fetchHistory(deviceSN: deviceSN, variables: variables)
    }
}

private extension NetworkCache {
    func makeKey(base: String, arguments: String...) -> String {
        ([base] + arguments).joined(separator: "_")
    }

    private func store(key: String, value: CachedItem) {
        serialiserQueue.sync {
            cache[key] = value
        }
    }
}
