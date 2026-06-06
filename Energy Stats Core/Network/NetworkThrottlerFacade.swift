//
//  NetworkThrottlerFacade.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 05/06/2026.
//

import Foundation

class NetworkThrottlerFacade: FoxAPIServicing {
    private let api: FoxAPIServicing
    private let throttler = ThrottleManager()
    private let writeAPIKey = "writeable-method" // All inverter write methods must delay 2s between each call, so use a shared key

    init(api: FoxAPIServicing) {
        self.api = api
    }

    func fetchErrorMessages() async {
        await api.fetchErrorMessages()
    }

    func openapi_fetchDeviceList() async throws -> [DeviceSummaryResponse] {
        try await throttle(method: #function, minimumDuration: 2.0) {
            try await api.openapi_fetchDeviceList()
        }
    }

    func openapi_fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse {
        try await api.openapi_fetchDevice(deviceSN: deviceSN)
    }

    func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        try await throttle(method: #function) {
            try await api.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
        }
    }

    func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        try await throttle(method: #function) {
            try await api.openapi_fetchHistory(deviceSN: deviceSN, variables: variables, start: start, end: end)
        }
    }

    func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        try await throttle(method: #function) {
            try await api.openapi_fetchVariables()
        }
    }

    func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        try await throttle(method: #function) {
            try await api.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)
        }
    }

    func openapi_fetchBatterySoc(deviceSN: String) async throws -> BatterySOCResponse {
        try await api.openapi_fetchBatterySoc(deviceSN: deviceSN)
    }

    func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {
        try await throttle(method: writeAPIKey, minimumDuration: 2.0) {
            try await api.openapi_setBatterySoc(deviceSN: deviceSN, minSOCOnGrid: minSOCOnGrid, minSOC: minSOC)
        }
    }

    func openapi_fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime] {
        try await api.openapi_fetchBatteryTimes(deviceSN: deviceSN)
    }

    func openapi_setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {
        try await throttle(method: writeAPIKey, minimumDuration: 2.0) {
            try await api.openapi_setBatteryTimes(deviceSN: deviceSN, times: times)
        }
    }

    func openapi_fetchDataLoggers() async throws -> [DataLoggerResponse] {
        try await throttle(method: #function) {
            try await api.openapi_fetchDataLoggers()
        }
    }

    func openapi_fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        try await api.openapi_fetchSchedulerFlag(deviceSN: deviceSN)
    }

    func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        try await throttle(method: #function) {
            try await api.openapi_fetchCurrentSchedule(deviceSN: deviceSN)
        }
    }

    func openapi_setScheduleFlag(deviceSN: String, enable: Bool) async throws {
        try await throttle(method: writeAPIKey, minimumDuration: 2.0) {
            try await api.openapi_setScheduleFlag(deviceSN: deviceSN, enable: enable)
        }
    }

    func openapi_saveSchedule(deviceSN: String, schedule: Schedule) async throws {
        try await throttle(method: writeAPIKey, minimumDuration: 2.0) {
            try await api.openapi_saveSchedule(deviceSN: deviceSN, schedule: schedule)
        }
    }

    func openapi_fetchPowerStationList() async throws -> PagedPowerStationListResponse {
        try await throttle(method: #function) {
            try await api.openapi_fetchPowerStationList()
        }
    }

    func openapi_fetchPowerStationDetail(stationID: String) async throws -> PowerStationDetailResponse {
        try await api.openapi_fetchPowerStationDetail(stationID: stationID)
    }

    func openapi_fetchRequestCount() async throws -> ApiRequestCountResponse {
        try await api.openapi_fetchRequestCount()
    }

    func openapi_fetchDeviceSettingsItem(deviceSN: String, item: DeviceSettingsItem) async throws -> FetchDeviceSettingsItemResponse {
        try await api.openapi_fetchDeviceSettingsItem(deviceSN: deviceSN, item: item)
    }

    func openapi_setDeviceSettingsItem(deviceSN: String, item: DeviceSettingsItem, value: String) async throws {
        try await throttle(method: writeAPIKey, minimumDuration: 2.0) {
            try await api.openapi_setDeviceSettingsItem(deviceSN: deviceSN, item: item, value: value)
        }
    }

    func openapi_fetchPeakShavingSettings(deviceSN: String) async throws -> FetchPeakShavingSettingsResponse {
        try await api.openapi_fetchPeakShavingSettings(deviceSN: deviceSN)
    }

    func openapi_setPeakShavingSettings(deviceSN: String, importLimit: Double, soc: Int) async throws {
        try await throttle(method: writeAPIKey, minimumDuration: 2.0) {
            try await api.openapi_setPeakShavingSettings(deviceSN: deviceSN, importLimit: importLimit, soc: soc)
        }
    }

    func openapi_fetchPowerGeneration(deviceSN: String) async throws -> PowerGenerationResponse {
        try await api.openapi_fetchPowerGeneration(deviceSN: deviceSN)
    }

    func openapi_getBatteryHeatingSchedule(deviceSN: String) async throws -> BatteryHeatingScheduleResponse {
        try await api.openapi_getBatteryHeatingSchedule(deviceSN: deviceSN)
    }

    func openapi_setBatteryHeatingSchedule(heatingScheduleRequest: BatteryHeatingScheduleRequest) async throws {
        try await throttle(method: writeAPIKey, minimumDuration: 2.0) {
            try await api.openapi_setBatteryHeatingSchedule(heatingScheduleRequest: heatingScheduleRequest)
        }
    }
}

private extension NetworkThrottlerFacade {
    func throttle<T>(method: String, minimumDuration: TimeInterval = 1.0, operation: () async throws -> T) async throws -> T {
        defer { throttler.didInvoke(method: method) }
        try await throttler.throttle(method: method, minimumDuration: minimumDuration)
        return try await operation()
    }
}

class ThrottleManager {
    private var lastCallTimes: [String: Date] = [:]
    private let queue = DispatchQueue(label: "throttle-manager-queue", qos: .utility)

    func throttle(method: String, minimumDuration: TimeInterval = 1.0) async throws {
        guard let lastCallTime = lastCallTime(for: method) else { return }

        let now = Date()
        let timeSinceLastCall = now.timeIntervalSince(lastCallTime)

        if timeSinceLastCall < minimumDuration {
            let waitTime = UInt64((minimumDuration - timeSinceLastCall) * 1_000_000_000)
            try await Task.sleep(nanoseconds: waitTime)
        }
    }

    func lastCallTime(for method: String) -> Date? {
        queue.sync {
            self.lastCallTimes[method]
        }
    }

    func didInvoke(method: String) {
        queue.sync {
            lastCallTimes[method] = Date()
        }
    }
}
