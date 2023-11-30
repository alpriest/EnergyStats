//
//  NetworkValueCleaner.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 20/10/2023.
//

import Foundation

public class NetworkValueCleaner: FoxESSNetworking {
    private let network: FoxESSNetworking

    public init(network: FoxESSNetworking) {
        self.network = network
    }

    public func ensureHasToken() async {
        await network.ensureHasToken()
    }

    public func verifyCredentials(username: String, hashedPassword: String) async throws {
        try await network.verifyCredentials(username: username, hashedPassword: hashedPassword)
    }

    public func fetchSchedulerFlag(deviceSN: String) async throws -> SchedulerFlagResponse {
        try await network.fetchSchedulerFlag(deviceSN: deviceSN)
    }

    public func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [ReportResponse] {
        try await network.fetchReport(deviceID: deviceID, variables: variables, queryDate: queryDate, reportType: reportType)
            .map { original in
                ReportResponse(variable: original.variable, data: original.data.map { originalData in
                    ReportResponse.ReportData(index: originalData.index, value: originalData.value.capped())
                })
            }
    }

    public func fetchBattery(deviceID: String) async throws -> BatteryResponse {
        try await network.fetchBattery(deviceID: deviceID)
    }

    public func fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse {
        try await network.fetchBatterySettings(deviceSN: deviceSN)
    }

    public func fetchRaw(deviceID: String, variables: [RawVariable], queryDate: QueryDate) async throws -> [RawResponse] {
        try await network.fetchRaw(deviceID: deviceID, variables: variables, queryDate: queryDate)
            .map { original in
                RawResponse(variable: original.variable, data: original.data.map { originalData in
                    RawResponse.ReportData(time: originalData.time, value: originalData.value.capped())
                })
            }
    }

    public func fetchDeviceList() async throws -> [PagedDeviceListResponse.Device] {
        try await network.fetchDeviceList()
    }

    public func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse {
        try await network.fetchAddressBook(deviceID: deviceID)
    }

    public func fetchVariables(deviceID: String) async throws -> [RawVariable] {
        try await network.fetchVariables(deviceID: deviceID)
    }

    public func fetchEarnings(deviceID: String) async throws -> EarningsResponse {
        try await network.fetchEarnings(deviceID: deviceID)
    }

    public func setSoc(minGridSOC: Int, minSOC: Int, deviceSN: String) async throws {
        try await network.setSoc(minGridSOC: minGridSOC, minSOC: minSOC, deviceSN: deviceSN)
    }

    public func fetchBatteryTimes(deviceSN: String) async throws -> BatteryTimesResponse {
        try await network.fetchBatteryTimes(deviceSN: deviceSN)
    }

    public func setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {
        try await network.setBatteryTimes(deviceSN: deviceSN, times: times)
    }

    public func fetchWorkMode(deviceID: String) async throws -> DeviceSettingsGetResponse {
        try await network.fetchWorkMode(deviceID: deviceID)
    }

    public func setWorkMode(deviceID: String, workMode: InverterWorkMode) async throws {
        try await network.setWorkMode(deviceID: deviceID, workMode: workMode)
    }

    public func fetchDataLoggers() async throws -> PagedDataLoggerListResponse {
        try await network.fetchDataLoggers()
    }

    public func fetchErrorMessages() async {
        await network.fetchErrorMessages()
    }
}

extension Double {
    func capped() -> Double {
        guard self > 0 else { return self }

        let register = Int(self * 10)
        let mask = 0xfff00000
        let masked = register & mask
        if masked == 0 {
            return self
        } else {
            return self - (Double(masked) / 10.0).rounded(decimalPlaces: 3)
        }
    }

    func sameValueAs(other: Double) -> Bool {
        abs(self - other) < 0.0000001
    }
}
