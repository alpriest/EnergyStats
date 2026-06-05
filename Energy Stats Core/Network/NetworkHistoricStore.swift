//
//  NetworkHistoricStore.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 04/06/2026.
//

import CryptoKit
import Foundation

class NetworkHistoricStore: FoxAPIServicing {
    private let api: FoxAPIServicing
    private let fileManager: FileManaging
    private var reportCache: [String: [OpenReportResponse]] = [:]
    
    init(api: FoxAPIServicing, fileManager: FileManaging = FileManager.default) {
        self.api = api
        self.fileManager = fileManager
    }

    func fetchErrorMessages() async {
        await api.fetchErrorMessages()
    }

    func openapi_fetchDeviceList() async throws -> [DeviceSummaryResponse] {
        try await api.openapi_fetchDeviceList()
    }

    func openapi_fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse {
        try await api.openapi_fetchDevice(deviceSN: deviceSN)
    }

    func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        try await api.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
    }

    func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        try await api.openapi_fetchHistory(deviceSN: deviceSN, variables: variables, start: start, end: end)
    }

    func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        try await api.openapi_fetchVariables()
    }

    func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        if isCurrentReportPeriod(queryDate: queryDate, reportType: reportType) {
            return try await api.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)
        }

        let key = makeReportCacheKey(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)

        if let cached = reportCache[key] {
            return cached
        }

        if let fileURL = makeReportCacheFileURL(key: key),
           fileManager.fileExists(atPath: fileURL.path),
           let data = fileManager.contents(atPath: fileURL.path)
        {
            let cached = try JSONDecoder().decode([OpenReportResponse].self, from: data)
            reportCache[key] = cached
            return cached
        }

        let fresh = try await api.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)
        reportCache[key] = fresh

        if let fileURL = makeReportCacheFileURL(key: key) {
            try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            let data = try JSONEncoder().encode(fresh)
            guard fileManager.createFile(atPath: fileURL.path, contents: data, attributes: nil) else {
                throw CocoaError(.fileWriteUnknown)
            }
        }

        return fresh
    }

    func openapi_fetchBatterySoc(deviceSN: String) async throws -> BatterySOCResponse {
        try await api.openapi_fetchBatterySoc(deviceSN: deviceSN)
    }

    func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {
        try await api.openapi_setBatterySoc(deviceSN: deviceSN, minSOCOnGrid: minSOCOnGrid, minSOC: minSOC)
    }

    func openapi_fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime] {
        try await api.openapi_fetchBatteryTimes(deviceSN: deviceSN)
    }

    func openapi_setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {
        try await api.openapi_setBatteryTimes(deviceSN: deviceSN, times: times)
    }

    func openapi_fetchDataLoggers() async throws -> [DataLoggerResponse] {
        try await api.openapi_fetchDataLoggers()
    }

    func openapi_fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        try await api.openapi_fetchSchedulerFlag(deviceSN: deviceSN)
    }

    func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        try await api.openapi_fetchCurrentSchedule(deviceSN: deviceSN)
    }

    func openapi_setScheduleFlag(deviceSN: String, enable: Bool) async throws {
        try await api.openapi_setScheduleFlag(deviceSN: deviceSN, enable: enable)
    }

    func openapi_saveSchedule(deviceSN: String, schedule: Schedule) async throws {
        try await api.openapi_saveSchedule(deviceSN: deviceSN, schedule: schedule)
    }

    func openapi_fetchPowerStationList() async throws -> PagedPowerStationListResponse {
        try await api.openapi_fetchPowerStationList()
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
        try await api.openapi_setDeviceSettingsItem(deviceSN: deviceSN, item: item, value: value)
    }

    func openapi_fetchPeakShavingSettings(deviceSN: String) async throws -> FetchPeakShavingSettingsResponse {
        try await api.openapi_fetchPeakShavingSettings(deviceSN: deviceSN)
    }

    func openapi_setPeakShavingSettings(deviceSN: String, importLimit: Double, soc: Int) async throws {
        try await api.openapi_setPeakShavingSettings(deviceSN: deviceSN, importLimit: importLimit, soc: soc)
    }

    func openapi_fetchPowerGeneration(deviceSN: String) async throws -> PowerGenerationResponse {
        try await api.openapi_fetchPowerGeneration(deviceSN: deviceSN)
    }

    func openapi_getBatteryHeatingSchedule(deviceSN: String) async throws -> BatteryHeatingScheduleResponse {
        try await api.openapi_getBatteryHeatingSchedule(deviceSN: deviceSN)
    }

    func openapi_setBatteryHeatingSchedule(heatingScheduleRequest: BatteryHeatingScheduleRequest) async throws {
        try await api.openapi_setBatteryHeatingSchedule(heatingScheduleRequest: heatingScheduleRequest)
    }

    func clear() throws {
        reportCache.removeAll()

        guard let directoryURL = makeReportCacheDirectoryURL(),
              fileManager.fileExists(atPath: directoryURL.path)
        else { return }

        try fileManager.removeItem(at: directoryURL)
    }
}

private extension NetworkHistoricStore {
    func makeReportCacheDirectoryURL() -> URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("network-historic-store", isDirectory: true)
    }

    func makeReportCacheFileURL(key: String) -> URL? {
        makeReportCacheDirectoryURL()?
            .appendingPathComponent("\(safeFileName(key)).json")
    }

    func makeReportCacheKey(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) -> String {
        [
            deviceSN,
            variables.sorted().map { $0.networkTitle }.joined(separator: ","),
            "\(queryDate.year)-\(queryDate.month ?? 0)-\(queryDate.day ?? 0)",
            reportType.rawValue
        ].joined(separator: "_")
    }

    func isCurrentReportPeriod(queryDate: QueryDate, reportType: ReportType) -> Bool {
        let now = QueryDate.now()

        switch reportType {
        case .year:
            return queryDate.year == now.year
        case .month:
            return queryDate.year == now.year && queryDate.month == now.month
        case .day:
            return queryDate.year == now.year && queryDate.month == now.month && queryDate.day == now.day
        }
    }

    func safeFileName(_ value: String) -> String {
        SHA256.hash(data: Data(value.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

