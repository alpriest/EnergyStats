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
    private let throwOnCall: Bool
    private let dateProvider: () -> Date

    init(throwOnCall: Bool = false, dateProvider: @escaping () -> Date = { Date() }) {
        self.throwOnCall = throwOnCall
        self.dateProvider = dateProvider
    }

    func fetchErrorMessages() async {}

    private func rawData() throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: "raw-success", withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }

    func openapi_fetchDeviceList() async throws -> [Energy_Stats_Core.DeviceDetailResponse] {
        []
    }

    func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> Energy_Stats_Core.OpenQueryResponse {
        OpenQueryResponse(time: Date(), deviceSN: "", datas: [])
    }

    func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> Energy_Stats_Core.OpenHistoryResponse {
        OpenHistoryResponse(deviceSN: "", datas: [])
    }

    func openapi_fetchVariables() async throws -> [Energy_Stats_Core.OpenApiVariable] {
        []
    }

    func openapi_fetchReport(deviceSN: String, variables: [Energy_Stats_Core.ReportVariable], queryDate: Energy_Stats_Core.QueryDate, reportType: Energy_Stats_Core.ReportType) async throws -> [Energy_Stats_Core.OpenReportResponse] {
        []
    }

    func openapi_fetchBatterySettings(deviceSN: String) async throws -> Energy_Stats_Core.BatterySOCResponse {
        BatterySOCResponse(minSocOnGrid: 0, minSoc: 0)
    }

    func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {}

    func openapi_setBatteryTimes(deviceSN: String, times: [Energy_Stats_Core.ChargeTime]) async throws {}

    func openapi_fetchBatteryTimes(deviceSN: String) async throws -> [Energy_Stats_Core.ChargeTime] {
        [ChargeTime(enable: false, startTime: Time(hour: 01, minute: 00), endTime: Time(hour: 01, minute: 30)),
         ChargeTime(enable: false, startTime: Time(hour: 03, minute: 00), endTime: Time(hour: 03, minute: 30))]
    }

    func openapi_fetchDataLoggers() async throws -> [Energy_Stats_Core.DataLoggerResponse] {
        [
            DataLoggerResponse(moduleSN: "ABC123DEF456", stationID: "John Doe 1", status: .online, signal: 3),
            DataLoggerResponse(moduleSN: "123DEF456ABC", stationID: "Jane Doe 2", status: .online, signal: 1)
        ]
    }

    func openapi_fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        GetSchedulerFlagResponse(enable: true, support: true)
    }

    func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        ScheduleResponse(enable: true.intValue, groups: [])
    }

    func openapi_setScheduleFlag(deviceSN: String, enable: Bool) async throws {}

    func openapi_saveSchedule(deviceSN: String, schedule: Energy_Stats_Core.Schedule) async throws {}
}
