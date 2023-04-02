//
//  NetworkFacade.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/10/2022.
//

import Foundation

class NetworkFacade: Networking {
    private let network: Networking
    private let fakeNetwork: Networking
    private let config: Config

    init(network: Networking, config: Config) {
        self.network = network
        self.fakeNetwork = DemoNetworking()
        self.config = config
    }

    func ensureHasToken() async {
        if config.isDemoUser {
            await fakeNetwork.ensureHasToken()
        }

        await network.ensureHasToken()
    }

    func verifyCredentials(username: String, hashedPassword: String) async throws {
        if config.isDemoUser {
            try await fakeNetwork.verifyCredentials(username: username, hashedPassword: hashedPassword)
        }

        try await network.verifyCredentials(username: username, hashedPassword: hashedPassword)
    }

    func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate) async throws -> [ReportResponse] {
        if config.isDemoUser {
            return try await fakeNetwork.fetchReport(deviceID: deviceID, variables: variables, queryDate: queryDate)
        }

        return try await network.fetchReport(deviceID: deviceID, variables: variables, queryDate: queryDate)
    }

    func fetchBattery(deviceID: String) async throws -> BatteryResponse {
        if config.isDemoUser {
            return try await fakeNetwork.fetchBattery(deviceID: deviceID)
        }

        return try await network.fetchBattery(deviceID: deviceID)
    }

    func fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse {
        if config.isDemoUser {
            return try await fakeNetwork.fetchBatterySettings(deviceSN: deviceSN)
        }

        return try await network.fetchBatterySettings(deviceSN: deviceSN)
    }

    func fetchRaw(deviceID: String, variables: [RawVariable]) async throws -> [RawResponse] {
        if config.isDemoUser {
            return try await fakeNetwork.fetchRaw(deviceID: deviceID, variables: variables)
        }

        return try await network.fetchRaw(deviceID: deviceID, variables: variables)
    }

    func fetchDeviceList() async throws -> PagedDeviceListResponse {
        if config.isDemoUser {
            return try await fakeNetwork.fetchDeviceList()
        }

        return try await network.fetchDeviceList()
    }

    func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse {
        if config.isDemoUser {
            return try await fakeNetwork.fetchAddressBook(deviceID: deviceID)
        }

        return try await network.fetchAddressBook(deviceID: deviceID)
    }
}
