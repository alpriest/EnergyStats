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

    public private(set) var reportResponse: [ReportResponse] = []
    public func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate) async throws -> [ReportResponse] {
        let result = try await inner.fetchReport(deviceID: deviceID, variables: variables, queryDate: queryDate)
        self.reportResponse = result
        return result
    }

    public private(set) var batteryResponse: BatteryResponse?
    public func fetchBattery(deviceID: String) async throws -> BatteryResponse {
        let result = try await inner.fetchBattery(deviceID: deviceID)
        self.batteryResponse = result
        return result
    }

    public private(set) var batterySettingsResponse: BatterySettingsResponse?
    public func fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse {
        let result = try await inner.fetchBatterySettings(deviceSN: deviceSN)
        self.batterySettingsResponse = result
        return result
    }

    @Published public private(set) var rawResponse: [RawResponse] = []
    public func fetchRaw(deviceID: String, variables: [RawVariable]) async throws -> [RawResponse] {
        let result = try await inner.fetchRaw(deviceID: deviceID, variables: variables)
        self.rawResponse = result
        return result
    }

    public private(set) var deviceListResponse: PagedDeviceListResponse?
    public func fetchDeviceList() async throws -> PagedDeviceListResponse {
        let result = try await inner.fetchDeviceList()
        self.deviceListResponse = result
        return result
    }

    public private(set) var fetchAddressBookResponse: AddressBookResponse?
    public func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse {
        let result = try await inner.fetchAddressBook(deviceID: deviceID)
        self.fetchAddressBookResponse = result
        return result
    }
}
