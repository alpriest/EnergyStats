//
//  MockNetworking.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

@testable import Energy_Stats
import Foundation

class MockNetworking: Networking {
    private let throwOnCall: Bool

    init(throwOnCall: Bool = false) {
        self.throwOnCall = throwOnCall
    }

    func ensureHasToken() async {
        // Assume valid
    }

    func fetchBatterySOC() async throws -> BatterySettingsResponse {
        BatterySettingsResponse(minSoc: 20)
    }

    func verifyCredentials(username: String, hashedPassword: String) async throws {
        if throwOnCall {
            throw NetworkError.badCredentials
        }
    }

    func fetchDeviceList() async throws -> PagedDeviceListResponse {
        PagedDeviceListResponse(currentPage: 1, pageSize: 1, total: 1, devices: [
            PagedDeviceListResponse.Device(deviceID: "abcdef", deviceSN: "123123", hasBattery: true, hasPV: true)
        ])
    }

    func fetchReport(variables: [VariableType]) async throws -> [ReportResponse] {
        if throwOnCall {
            throw NetworkError.unknown
        }

        return [ReportResponse(variable: "feedin", data: [.init(index: 14, value: 1.5)])]
    }

    func fetchBatterySettings() async throws -> BatterySettingsResponse {
        BatterySettingsResponse(minSoc: 20)
    }

    func fetchBattery() async throws -> BatteryResponse {
        BatteryResponse(power: 0.27, soc: 56, residual: 2200)
    }

    func fetchRaw(variables: [VariableType]) async throws -> [RawResponse] {
        if throwOnCall {
            throw NetworkError.unknown
        }

        let response = try JSONDecoder().decode(NetworkResponse<[RawResponse]>.self, from: rawData())
        guard let result = response.result else { throw NetworkError.invalidToken }

        return result.map {
            RawResponse(variable: $0.variable, data: $0.data.map {
                let components = Calendar.current.dateComponents([.hour, .minute, .second], from: $0.time)

                let date = Calendar.current.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: components.second ?? 0, of: Date())

                return RawResponse.ReportData(time: date ?? $0.time, value: $0.value)
            })
        }
    }

    private func rawData() throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: "raw-success", withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }
}
