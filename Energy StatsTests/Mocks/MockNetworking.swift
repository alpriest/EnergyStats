//
//  MockNetworking.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

@testable import Energy_Stats
@testable import Energy_Stats_Core
import Foundation

class MockNetworking: FoxESSNetworking {
    private let throwOnCall: Bool
    private let dateProvider: () -> Date

    init(throwOnCall: Bool = false, dateProvider: @escaping () -> Date = { Date() }) {
        self.throwOnCall = throwOnCall
        self.dateProvider = dateProvider
    }

    func ensureHasToken() async {
        // Assume valid
    }

    func fetchBatterySOC() async throws -> BatterySOCResponse {
        BatterySOCResponse(minSocOnGrid: 15, minSoc: 20)
    }

    func verifyCredentials(username: String, hashedPassword: String) async throws {
        if throwOnCall {
            throw NetworkError.badCredentials
        }
    }

    func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate) async throws -> [ReportResponse] {
        if throwOnCall {
            throw NetworkError.maintenanceMode
        }

        return [ReportResponse(variable: "feedin", data: [.init(index: 14, value: 1.5)])]
    }

    func fetchBatterySettings(deviceSN: String) async throws -> BatterySOCResponse {
        BatterySOCResponse(minSocOnGrid: 15, minSoc: 20)
    }

    func fetchErrorMessages() async {}

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

    func fetchSchedulerFlag(deviceSN: String) async throws -> Energy_Stats_Core.SchedulerFlagResponse {
        SchedulerFlagResponse(enable: true, support: true)
    }

    func fetchScheduleModes(deviceID: String) async throws -> [Energy_Stats_Core.SchedulerModeResponse] {
        []
    }

    func fetchCurrentSchedule(deviceSN: String) async throws -> Energy_Stats_Core.ScheduleListResponse {
        ScheduleListResponse(data: [], enable: false, pollcy: [])
    }

    func saveSchedule(deviceSN: String, schedule: Energy_Stats_Core.Schedule) async throws {}

    func saveScheduleTemplate(deviceSN: String, template: Energy_Stats_Core.ScheduleTemplate) async throws {}

    func deleteSchedule(deviceSN: String) async throws {}

    func createScheduleTemplate(name: String, description: String) async throws {}

    func fetchScheduleTemplates() async throws -> Energy_Stats_Core.ScheduleTemplateListResponse {
        ScheduleTemplateListResponse(data: [])
    }

    func enableScheduleTemplate(deviceSN: String, templateID: String) async throws {}

    func fetchScheduleTemplate(deviceSN: String, templateID: String) async throws -> Energy_Stats_Core.ScheduleTemplateResponse {
        ScheduleTemplateResponse(templateName: "", enable: false, pollcy: [], content: "")
    }

    func deleteScheduleTemplate(templateID: String) async throws {}

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

    func openapi_fetchBatteryTimes(deviceSN: String) async throws -> Energy_Stats_Core.BatteryTimesResponse {
        BatteryTimesResponse(times: [
            ChargeTime(enable: false, startTime: Time(hour: 01, minute: 00), endTime: Time(hour: 01, minute: 30)),
            ChargeTime(enable: false, startTime: Time(hour: 03, minute: 00), endTime: Time(hour: 03, minute: 30))
        ])
    }

    func openapi_setBatteryTimes(deviceSN: String, times: [Energy_Stats_Core.ChargeTime]) async throws {}
}
