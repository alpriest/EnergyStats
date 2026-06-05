//
//  NetworkDemoSwitchingFacade.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/10/2022.
//

import Foundation

class NetworkDemoSwitchingFacade: FoxAPIServicing {
    private let api: FoxAPIServicing
    private let demoAPI: FoxAPIServicing
    private let isDemoUserProvider: () -> Bool

    init(api: FoxAPIServicing, isDemoUser provider: @escaping () -> Bool) {
        self.api = api
        self.demoAPI = DemoAPI()
        self.isDemoUserProvider = provider
    }

    private var activeAPI: FoxAPIServicing {
        isDemoUserProvider() ? demoAPI : api
    }

    func fetchErrorMessages() async {
        await activeAPI.fetchErrorMessages()
    }

    func openapi_fetchDeviceList() async throws -> [DeviceSummaryResponse] {
        try await activeAPI.openapi_fetchDeviceList()
    }

    func openapi_fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse {
        try await activeAPI.openapi_fetchDevice(deviceSN: deviceSN)
    }

    func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        try await activeAPI.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
    }

    func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        try await activeAPI.openapi_fetchHistory(deviceSN: deviceSN, variables: variables, start: start, end: end)
    }

    func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        try await activeAPI.openapi_fetchVariables()
    }

    func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        try await activeAPI.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)
    }

    func openapi_fetchBatterySoc(deviceSN: String) async throws -> BatterySOCResponse {
        try await activeAPI.openapi_fetchBatterySoc(deviceSN: deviceSN)
    }

    func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {
        try await activeAPI.openapi_setBatterySoc(deviceSN: deviceSN, minSOCOnGrid: minSOCOnGrid, minSOC: minSOC)
    }

    func openapi_fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime] {
        try await activeAPI.openapi_fetchBatteryTimes(deviceSN: deviceSN)
    }

    func openapi_setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {
        try await activeAPI.openapi_setBatteryTimes(deviceSN: deviceSN, times: times)
    }

    func openapi_fetchDataLoggers() async throws -> [DataLoggerResponse] {
        try await activeAPI.openapi_fetchDataLoggers()
    }

    func openapi_fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        try await activeAPI.openapi_fetchSchedulerFlag(deviceSN: deviceSN)
    }

    func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        try await activeAPI.openapi_fetchCurrentSchedule(deviceSN: deviceSN)
    }

    func openapi_setScheduleFlag(deviceSN: String, enable: Bool) async throws {
        try await activeAPI.openapi_setScheduleFlag(deviceSN: deviceSN, enable: enable)
    }

    func openapi_saveSchedule(deviceSN: String, schedule: Schedule) async throws {
        try await activeAPI.openapi_saveSchedule(deviceSN: deviceSN, schedule: schedule)
    }

    func openapi_fetchPowerStationList() async throws -> PagedPowerStationListResponse {
        try await activeAPI.openapi_fetchPowerStationList()
    }

    func openapi_fetchPowerStationDetail(stationID: String) async throws -> PowerStationDetailResponse {
        try await activeAPI.openapi_fetchPowerStationDetail(stationID: stationID)
    }

    func openapi_fetchRequestCount() async throws -> ApiRequestCountResponse {
        try await activeAPI.openapi_fetchRequestCount()
    }

    func openapi_fetchDeviceSettingsItem(deviceSN: String, item: DeviceSettingsItem) async throws -> FetchDeviceSettingsItemResponse {
        try await activeAPI.openapi_fetchDeviceSettingsItem(deviceSN: deviceSN, item: item)
    }

    func openapi_setDeviceSettingsItem(deviceSN: String, item: DeviceSettingsItem, value: String) async throws {
        try await activeAPI.openapi_setDeviceSettingsItem(deviceSN: deviceSN, item: item, value: value)
    }

    func openapi_fetchPeakShavingSettings(deviceSN: String) async throws -> FetchPeakShavingSettingsResponse {
        try await activeAPI.openapi_fetchPeakShavingSettings(deviceSN: deviceSN)
    }

    func openapi_setPeakShavingSettings(deviceSN: String, importLimit: Double, soc: Int) async throws {
        try await activeAPI.openapi_setPeakShavingSettings(deviceSN: deviceSN, importLimit: importLimit, soc: soc)
    }

    func openapi_fetchPowerGeneration(deviceSN: String) async throws -> PowerGenerationResponse {
        try await activeAPI.openapi_fetchPowerGeneration(deviceSN: deviceSN)
    }

    func openapi_getBatteryHeatingSchedule(deviceSN: String) async throws -> BatteryHeatingScheduleResponse {
        try await activeAPI.openapi_getBatteryHeatingSchedule(deviceSN: deviceSN)
    }

    func openapi_setBatteryHeatingSchedule(heatingScheduleRequest: BatteryHeatingScheduleRequest) async throws {
        try await activeAPI.openapi_setBatteryHeatingSchedule(heatingScheduleRequest: heatingScheduleRequest)
    }
}
