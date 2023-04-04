//
//  DemoNetworking.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Foundation

public class DemoNetworking: Networking {
    private let throwOnCall: Bool

    public init(throwOnCall: Bool = false) {
        self.throwOnCall = throwOnCall
    }

    public func ensureHasToken() async {
        // Do nothing
    }

    public func verifyCredentials(username: String, hashedPassword: String) async throws {
        // Assume mock credentials are valid
    }

    public func fetchBattery(deviceID: String) async throws -> BatteryResponse {
        BatteryResponse(power: 0.28, soc: 76, residual: 7550, temperature: 17.3)
    }

    public func fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse {
        BatterySettingsResponse(minSoc: 20)
    }

    public func fetchDeviceList() async throws -> PagedDeviceListResponse {
        PagedDeviceListResponse(currentPage: 1, pageSize: 1, total: 1, devices: [
            PagedDeviceListResponse.Device(plantName: "demo-device-1", deviceID: "abcdef1abcdef1abcdef1", deviceSN: "1234", hasBattery: true, hasPV: true),
            PagedDeviceListResponse.Device(plantName: "demo-device-2", deviceID: "abcdef2abcdef2abcdef2", deviceSN: "5678", hasBattery: true, hasPV: true)
        ])
    }

    public func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate) async throws -> [ReportResponse] {
        if throwOnCall {
            throw NetworkError.unknown
        }

        let response = try JSONDecoder().decode(NetworkResponse<[ReportResponse]>.self, from: reportData())
        guard let result = response.result else { throw NetworkError.invalidToken }

        return result
    }

    public func fetchRaw(deviceID: String, variables: [RawVariable]) async throws -> [RawResponse] {
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

    public func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse {
        AddressBookResponse(softVersion: AddressBookResponse.SoftwareVersion(master: "1.54", slave: "1.02", manager: "1.57"))
    }

    private func rawData() throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: "raw", withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }

    private func reportData() throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: "report", withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }
}

public class MockConfig: Config {
    public init() {}

    public var showBatteryEstimate: Bool = true
    public var batteryCapacity: String?
    public var minSOC: String?
    public var deviceID: String?
    public var deviceSN: String?
    public var hasBattery: Bool = true
    public var hasPV: Bool = true
    public var isDemoUser: Bool = true
    public var showColouredLines: Bool = true
    public var showBatteryTemperature: Bool = true
    public var refreshFrequency: Int = 0
    public var decimalPlaces: Int = 3
    public var showSunnyBackground: Bool = true
    public var devices: Data?
    public var selectedDeviceID: String?
    public var showUsableBatteryOnly: Bool = false
}

public class PreviewConfigManager: ConfigManager {
    public convenience init() {
        self.init(networking: DemoNetworking(), config: MockConfig())
        Task { try await findDevices() }
    }

    public override var devices: [Device]? {
        get {
            [
                Device(plantName: "demo-device-1", deviceID: "03274209-486c-4ea3-9c28-159f25ee84cb", deviceSN: "1234", hasPV: true, battery: nil),
                Device(plantName: "demo-device-2", deviceID: "03274209-486c-4ea3-9c28-662625ee84cb", deviceSN: "5678", hasPV: true, battery: nil)
            ]
        }
        set {}
    }
}
