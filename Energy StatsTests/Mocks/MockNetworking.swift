//
//  MockNetworking.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

@testable import Energy_Stats
@testable import Energy_Stats_Core
import Foundation

class MockNetworking: Networking {
    func fetchVariables(deviceID: String) async throws -> [RawVariable] {
        [
            RawVariable(name: "Output Power", variable: "generationPower", unit: "kW"),
            RawVariable(name: "Feed-in Power", variable: "feedinPower", unit: "kW"),
            RawVariable(name: "Charge Power", variable: "batChargePower", unit: "kW"),
            RawVariable(name: "Discharge Power", variable: "batDischargePower", unit: "kW"),
            RawVariable(name: "GridConsumption Power", variable: "gridConsumptionPower", unit: "kW")
        ]
    }

    private let throwOnCall: Bool
    private let dateProvider: () -> Date

    init(throwOnCall: Bool = false, dateProvider: @escaping () -> Date = { Date() }) {
        self.throwOnCall = throwOnCall
        self.dateProvider = dateProvider
    }

    func ensureHasToken() async {
        // Assume valid
    }

    func fetchBatterySOC() async throws -> BatterySettingsResponse {
        BatterySettingsResponse(minGridSoc: 15, minSoc: 20)
    }

    func verifyCredentials(username: String, hashedPassword: String) async throws {
        if throwOnCall {
            throw NetworkError.badCredentials
        }
    }

    func fetchDeviceList() async throws -> [PagedDeviceListResponse.Device] {
        [
            PagedDeviceListResponse.Device(plantName: "plant1", deviceID: "abcdef", deviceSN: "123123", moduleSN: "SN123", hasBattery: true, hasPV: true, deviceType: "F4000")
        ]
    }

    func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate) async throws -> [ReportResponse] {
        if throwOnCall {
            throw NetworkError.maintenanceMode
        }

        return [ReportResponse(variable: "feedin", data: [.init(index: 14, value: 1.5)])]
    }

    func fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse {
        BatterySettingsResponse(minGridSoc: 15, minSoc: 20)
    }

    func fetchBattery(deviceID: String) async throws -> BatteryResponse {
        BatteryResponse(power: 0.27, soc: 56, residual: 2200, temperature: 13.6)
    }

    func fetchErrorMessages() async {

    }

    func fetchRaw(deviceID: String, variables: [RawVariable], queryDate: Energy_Stats_Core.QueryDate) async throws -> [RawResponse] {
        if throwOnCall {
            throw NetworkError.maintenanceMode
        }

        let response = try JSONDecoder().decode(NetworkResponse<[RawResponse]>.self, from: rawData())
        guard let result = response.result else { throw NetworkError.invalidToken }

        return result.map {
            RawResponse(variable: $0.variable, data: $0.data.map {
                let components = Calendar.current.dateComponents([.hour, .minute, .second], from: $0.time)

                let date = Calendar.current.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: components.second ?? 0, of: dateProvider())

                return RawResponse.ReportData(time: date ?? $0.time, value: $0.value)
            })
        }
    }

    func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse {
        AddressBookResponse(softVersion: AddressBookResponse.SoftwareVersion(master: "1", slave: "2", manager: "3"))
    }

    func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [ReportResponse] {
        []
    }

    func fetchEarnings(deviceID: String) async throws -> EarningsResponse {
        EarningsResponse(currency: "GBP", today: EarningsResponse.Earning(generation: 1.0, earnings: 1.0),
                         month: EarningsResponse.Earning(generation: 2.0, earnings: 2.0),
                         year: EarningsResponse.Earning(generation: 3.0, earnings: 3.0),
                         cumulate: EarningsResponse.Earning(generation: 4.0, earnings: 4.0))
    }

    func setSoc(minGridSOC: Int, minSOC: Int, deviceSN: String) async throws {}

    func fetchBatteryTimes(deviceSN: String) async throws -> BatteryTimesResponse {
        BatteryTimesResponse(sn: "ABC1234", times: [
            ChargeTime(enableGrid: false, startTime: Time(hour: 01, minute: 00), endTime: Time(hour: 01, minute: 30)),
            ChargeTime(enableGrid: false, startTime: Time(hour: 03, minute: 00), endTime: Time(hour: 03, minute: 30))
        ])
    }

    func setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {}

    func fetchWorkMode(deviceID: String) async throws -> DeviceSettingsGetResponse {
        DeviceSettingsGetResponse(protocol: "H1234", raw: "", values: InverterValues(operationModeWorkMode: .feedInFirst))
    }

    func setWorkMode(deviceID: String, workMode: InverterWorkMode) async throws {}

    func fetchDataLoggers() async throws -> PagedDataLoggerListResponse {
        PagedDataLoggerListResponse(currentPage: 1, pageSize: 10, total: 1, data: [
            PagedDataLoggerListResponse.DataLogger(moduleSN: "ABC123DEF456", moduleType: "W2", plantName: "John Doe", version: "3.08", signal: 3, communication: 1),
            PagedDataLoggerListResponse.DataLogger(moduleSN: "123DEF456ABC", moduleType: "W2", plantName: "Jane Doe", version: "3.08", signal: 1, communication: 0)
        ])
    }

    private func rawData() throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: "raw-success", withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }
}
