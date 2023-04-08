//
//  InMemoryLoggingNetworkingDecorator.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 05/04/2023.
//

import Foundation

public class InMemoryLoggingNetworkingDecorator: ObservableObject, Networking {
    private let inner: Networking

    public init(inner: Networking) {
        self.inner = inner
    }

    public func ensureHasToken() async {
        await self.inner.ensureHasToken()
    }

    public func verifyCredentials(username: String, hashedPassword: String) async throws {
        try await self.inner.verifyCredentials(username: username, hashedPassword: hashedPassword)
    }

    public private(set) var reportResponse: NetworkOperation<[ReportResponse]>?
    public func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate) async throws -> [ReportResponse] {
        let result = try await inner.fetchReport(deviceID: deviceID, variables: variables, queryDate: queryDate)
        self.reportResponse = NetworkOperation(description: "fetchReport", data: result)
        return result
    }

    public private(set) var batteryResponse: NetworkOperation<BatteryResponse>?
    public func fetchBattery(deviceID: String) async throws -> BatteryResponse {
        let result = try await inner.fetchBattery(deviceID: deviceID)
        self.batteryResponse = NetworkOperation(description: "fetchBattery", data: result)
        return result
    }

    public private(set) var batterySettingsResponse: NetworkOperation<BatterySettingsResponse>?
    public func fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse {
        let result = try await inner.fetchBatterySettings(deviceSN: deviceSN)
        self.batterySettingsResponse = NetworkOperation(description: "fetchBatterySettings", data: result)
        return result
    }

    @Published public private(set) var rawResponse: NetworkOperation<[RawResponse]>?
    public func fetchRaw(deviceID: String, variables: [RawVariable]) async throws -> [RawResponse] {
        let result = try await inner.fetchRaw(deviceID: deviceID, variables: variables)
        self.rawResponse = NetworkOperation(description: "fetchRaw", data: result)
        return result
    }

    public private(set) var deviceListResponse: NetworkOperation<PagedDeviceListResponse>?
    public func fetchDeviceList() async throws -> PagedDeviceListResponse {
        let result = try await inner.fetchDeviceList()
        self.deviceListResponse = NetworkOperation(description: "fetchDeviceList", data: result)
        return result
    }

    public private(set) var fetchAddressBookResponse: NetworkOperation<AddressBookResponse>?
    public func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse {
        let result = try await inner.fetchAddressBook(deviceID: deviceID)
        self.fetchAddressBookResponse = NetworkOperation(description: "fetchAddressBook", data: result)
        return result
    }
}

public struct NetworkOperation<T: Decodable> {
    public let time: Date = Date()
    public let description: String
    public let data: T
}
