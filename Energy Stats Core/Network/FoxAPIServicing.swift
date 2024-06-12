//
//  Networking.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

extension URL {
    static var errorMessages = URL(string: "https://www.foxesscloud.com/c/v0/errors/message")!
}

protocol FoxAPIServicing {
    func fetchErrorMessages() async

    func openapi_fetchDeviceList() async throws -> [DeviceSummaryResponse]
    func openapi_fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse
    func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse
    func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse
    func openapi_fetchVariables() async throws -> [OpenApiVariable]
    func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse]
    func openapi_fetchBatterySettings(deviceSN: String) async throws -> BatterySOCResponse
    func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws
    func openapi_fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime]
    func openapi_setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws
    func openapi_fetchDataLoggers() async throws -> [DataLoggerResponse]
    func openapi_fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse
    func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse
    func openapi_setScheduleFlag(deviceSN: String, enable: Bool) async throws
    func openapi_saveSchedule(deviceSN: String, schedule: Schedule) async throws
    func openapi_fetchPowerStationList() async throws -> PagedPowerStationListResponse
    func openapi_fetchPowerStationDetail(stationID: String) async throws -> PowerStationDetailResponse
    func openapi_fetchRequestCount() async throws -> ApiRequestCountResponse
}
