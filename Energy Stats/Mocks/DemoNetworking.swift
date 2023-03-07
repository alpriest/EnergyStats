//
//  DemoNetworking.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Foundation

class DemoNetworking: Networking {
    private let throwOnCall: Bool

    init(throwOnCall: Bool = false) {
        self.throwOnCall = throwOnCall
    }

    func ensureHasToken() async {
        // Do nothing
    }

    func verifyCredentials(username: String, hashedPassword: String) async throws {
        // Assume mock credentials are valid
    }

    func fetchBattery(deviceID: String) async throws -> BatteryResponse {
        BatteryResponse(power: 0.27, soc: 20, residual: 2420, temperature: 15.6)
    }

    func fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse {
        BatterySettingsResponse(minSoc: 20)
    }

    func fetchDeviceList() async throws -> PagedDeviceListResponse {
        PagedDeviceListResponse(currentPage: 1, pageSize: 1, total: 1, devices: [
            PagedDeviceListResponse.Device(plantName: "demo-device-1", deviceID: "abcdef1", deviceSN: "1234", hasBattery: true, hasPV: true),
            PagedDeviceListResponse.Device(plantName: "demo-device-2", deviceID: "abcdef2", deviceSN: "5678", hasBattery: true, hasPV: true)
        ])
    }

    func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate) async throws -> [ReportResponse] {
        if throwOnCall {
            throw NetworkError.unknown
        }

        return [ReportResponse(variable: "feedin", data: [.init(index: 14, value: 1.5)])]
    }

    func fetchRaw(deviceID: String, variables: [RawVariable]) async throws -> [RawResponse] {
        if throwOnCall {
            throw NetworkError.unknown
        }

        let response = try JSONDecoder().decode(NetworkResponse<[RawResponse]>.self, from: rawData())
        guard let result = response.result else { throw NetworkError.invalidToken }

        return result.map {
            RawResponse(variable: $0.variable, data: $0.data.map {
                let thenComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: $0.time)

                let date = Calendar.current.date(bySettingHour: thenComponents.hour ?? 0, minute: thenComponents.minute ?? 0, second: thenComponents.second ?? 0, of: Date())

                return RawResponse.ReportData(time: date ?? $0.time, value: $0.value)
            })
        }
    }

    private func rawData() throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: "raw", withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }
}

class MockConfig: Config {
    var batteryCapacity: String?
    var minSOC: String?
    var deviceID: String?
    var deviceSN: String?
    var hasBattery: Bool = true
    var hasPV: Bool = true
    var isDemoUser: Bool = true
    var showColouredLines: Bool = true
    var showBatteryTemperature: Bool = true
    var refreshFrequency: Int = 0
    var decimalPlaces: Int = 3
    var showSunnyBackground: Bool = true
    var devices: Data?
}

class MockConfigManager: ConfigManager {
    convenience init() {
        self.init(networking: DemoNetworking(), config: MockConfig())
    }
}
