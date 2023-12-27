//
//  NetworkFacade.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/10/2022.
//

import Foundation

public class NetworkFacade: FoxESSNetworking {
    private let network: FoxESSNetworking
    private let fakeNetwork: FoxESSNetworking
    private let config: Config
    private let store: KeychainStoring

    public init(network: FoxESSNetworking, config: Config, store: KeychainStoring) {
        self.network = network
        self.fakeNetwork = DemoNetworking()
        self.config = config
        self.store = store
    }

    private var isDemoUser: Bool {
        config.isDemoUser || store.isDemoUser
    }

    // TODO:
//    public func fetchVariables(deviceID: String) async throws -> [RawVariable] {
//        return if isDemoUser {
//            try await fakeNetwork.fetchVariables(deviceID: deviceID)
//        } else {
//            try await network.fetchVariables(deviceID: deviceID)
//        }
//    }

    public func fetchErrorMessages() async {
        if isDemoUser {
            await fakeNetwork.fetchErrorMessages()
        } else {
            await network.fetchErrorMessages()
        }
    }

    public func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        if isDemoUser {
            try await fakeNetwork.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
        } else {
            try await network.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
        }
    }

    public func openapi_fetchHistory(deviceSN: String, variables: [String]) async throws -> OpenHistoryResponse {
        if isDemoUser {
            try await fakeNetwork.openapi_fetchHistory(deviceSN: deviceSN, variables: variables)
        } else {
            try await network.openapi_fetchHistory(deviceSN: deviceSN, variables: variables)
        }
    }
}
