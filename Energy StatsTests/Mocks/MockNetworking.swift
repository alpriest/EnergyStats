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
    func fetchRequestCount() async throws -> ApiRequestCountResponse {
        ApiRequestCountResponse(total: "5", remaining: "0")
    }
    
    private let dateProvider: () -> Date
    private let callsToThrow: Set<DemoAPIRequest>

    init(callsToThrow: Set<DemoAPIRequest> = Set(), dateProvider: @escaping () -> Date = { Date() }) {
        self.callsToThrow = callsToThrow
        self.dateProvider = dateProvider
    }

    func fetchErrorMessages() async {}

    private func rawData() throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: "raw-success", withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }

    func fetchDeviceList() async throws -> [DeviceSummaryResponse] {
        if callsToThrow.contains(.openapi_fetchDeviceList) {
            throw NetworkError.badCredentials
        }

        return [
            DeviceSummaryResponse(
                deviceSN: "DEVICESN",
                moduleSN: "moduleSN",
                stationID: "stationID",
                stationName: "stationName",
                productType: "productType",
                deviceType: "deviceType",
                hasBattery: true,
                hasPV: true,
                status: 1
            )
        ]
    }

    func fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse {
        DeviceDetailResponse(deviceSN: "", moduleSN: "", stationID: "", stationName: "", managerVersion: "", masterVersion: "", slaveVersion: "", hardwareVersion: "", status: 0, function: DeviceDetailResponse.Function(scheduler: false), productType: "", deviceType: "", hasBattery: false, hasPV: false)
    }

    func fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        OpenQueryResponse(time: dateProvider(), deviceSN: "", datas: [])
    }

    func fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        if callsToThrow.contains(.openapi_fetchHistory) {
            throw NetworkError.badCredentials
        }

        let data = try self.data(filename: "parameters-history-success")
        let response = try JSONDecoder().decode(NetworkResponse<[OpenHistoryResponse]>.self, from: data)
        guard let result = response.result?.first else { throw NetworkError.invalidToken }

        return OpenHistoryResponse(deviceSN: result.deviceSN,
                                   datas: result.datas.map {
            OpenHistoryResponse.Data(
                unit: $0.unit,
                name: $0.name,
                variable: $0.variable,
                data: $0.data.map {
                    let thenComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: $0.time)
                    let date = Calendar.current.date(bySettingHour: thenComponents.hour ?? 0, minute: thenComponents.minute ?? 0, second: thenComponents.second ?? 0, of: dateProvider())

                    return OpenHistoryResponse.Data.UnitData(
                        time: date ?? $0.time,
                        value: $0.value
                    )
                }
            )
        })
    }

    func fetchVariables() async throws -> [OpenApiVariable] {
        let data = try self.data(filename: "variables-success")
        let response = try JSONDecoder().decode(NetworkResponse<OpenApiVariableArray>.self, from: data)
        guard let result = response.result else { throw NetworkError.invalidToken }
        return result.array
    }

    func fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        []
    }

    func fetchBatterySettings(deviceSN: String) async throws -> BatterySOCResponse {
        BatterySOCResponse(minSocOnGrid: 0, minSoc: 0)
    }

    func setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {}

    func setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {}

    func fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime] {
        [ChargeTime(enable: false, startTime: Time(hour: 01, minute: 00), endTime: Time(hour: 01, minute: 30)),
         ChargeTime(enable: false, startTime: Time(hour: 03, minute: 00), endTime: Time(hour: 03, minute: 30))]
    }

    func fetchDataLoggers() async throws -> [DataLoggerResponse] {
        [
            DataLoggerResponse(moduleSN: "ABC123DEF456", stationID: "John Doe 1", status: .online, signal: 3),
            DataLoggerResponse(moduleSN: "123DEF456ABC", stationID: "Jane Doe 2", status: .online, signal: 1)
        ]
    }

    func fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        GetSchedulerFlagResponse(enable: true, support: true)
    }

    func fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        ScheduleResponse(enable: true.intValue, groups: [])
    }

    func setScheduleFlag(deviceSN: String, enable: Bool) async throws {}

    func saveSchedule(deviceSN: String, schedule: Schedule) async throws {}

    func fetchPowerStationDetail() async throws -> PowerStationDetail? {
        nil
    }

    private func data(filename: String) throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: filename, withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }
}
