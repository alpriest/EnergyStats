//
//  NetworkCache.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 12/09/2023.
//

import Foundation

struct CachedItem {
    let cacheTime: Date
    let item: Codable

    init(_ item: Codable) {
        self.cacheTime = Date()
        self.item = item
    }

    func isFresherThan(interval: TimeInterval) -> Bool {
        abs(cacheTime.timeIntervalSinceNow) < interval
    }
}

class NetworkCache: FoxAPIServicing {
    private let api: FoxAPIServicing
    private var cache: [String: CachedItem] = [:]
    private let shortCacheDurationInSeconds: TimeInterval = 30
    private let longCacheDurationInSeconds: TimeInterval = 300
    private let serialiserQueue = DispatchQueue(label: "networkcache.write.queue")

    init(api: FoxAPIServicing) {
        self.api = api
    }

    func openapi_fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        try await api.openapi_fetchSchedulerFlag(deviceSN: deviceSN)
    }

    func openapi_setScheduleFlag(deviceSN: String, enable: Bool) async throws {
        try await api.openapi_setScheduleFlag(deviceSN: deviceSN, enable: enable)
    }

    func openapi_fetchBatterySettings(deviceSN: String) async throws -> BatterySOCResponse {
        try await api.openapi_fetchBatterySettings(deviceSN: deviceSN)
    }

    func openapi_fetchDeviceList() async throws -> [DeviceSummaryResponse] {
        let key = makeKey(base: #function)

        if let item = cache[key], let cached = item.item as? [DeviceSummaryResponse], item.isFresherThan(interval: longCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchDeviceList()
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    func openapi_fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse {
        let key = makeKey(base: #function, arguments: deviceSN)

        if let item = cache[key], let cached = item.item as? DeviceDetailResponse, item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchDevice(deviceSN: deviceSN)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
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
        let key = makeKey(base: #function)

        if let item = cache[key], let cached = item.item as? [DataLoggerResponse], item.isFresherThan(interval: longCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchDataLoggers()
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    func fetchErrorMessages() async {
        await api.fetchErrorMessages()
    }

    func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        let key = makeKey(base: #function, arguments: deviceSN, variables.sorted().joined(separator: "_"))

        if let item = cache[key], let cached = item.item as? OpenQueryResponse, item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        let key = makeKey(base: #function, arguments: deviceSN, variables.sorted().joined(separator: "_"), String(start.timeIntervalSince1970), String(end.timeIntervalSince1970))

        if let item = cache[key], let cached = item.item as? OpenHistoryResponse, item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchHistory(deviceSN: deviceSN, variables: variables, start: start, end: end)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        let key = makeKey(base: #function)

        if let item = cache[key], let cached = item.item as? [OpenApiVariable], item.isFresherThan(interval: longCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchVariables()
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        let key = makeKey(base: #function, arguments: deviceSN, variables.map { $0.networkTitle }.sorted().joined(separator: "_"), queryDate.toString(), reportType.rawValue)

        if let item = cache[key], let cached = item.item as? [OpenReportResponse], item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        try await api.openapi_fetchCurrentSchedule(deviceSN: deviceSN)
    }

    func openapi_saveSchedule(deviceSN: String, schedule: Schedule) async throws {
        try await api.openapi_saveSchedule(deviceSN: deviceSN, schedule: schedule)
    }

    func openapi_fetchPowerStationList() async throws -> PagedPowerStationListResponse {
        let key = makeKey(base: #function)

        if let item = cache[key], let cached = item.item as? PagedPowerStationListResponse, item.isFresherThan(interval: longCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchPowerStationList()
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    func openapi_fetchPowerStationDetail(stationID: String) async throws -> PowerStationDetailResponse {
        let key = makeKey(base: #function, arguments: stationID)

        if let item = cache[key], let cached = item.item as? PowerStationDetailResponse, item.isFresherThan(interval: longCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchPowerStationDetail(stationID: stationID)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    func openapi_fetchRequestCount() async throws -> ApiRequestCountResponse {
        try await api.openapi_fetchRequestCount()
    }
}

private extension NetworkCache {
    func makeKey(base: String, arguments: String?...) -> String {
        ([base] + arguments.compactMap { $0 }).joined(separator: "_")
    }

    private func store(key: String, value: CachedItem) {
        serialiserQueue.sync {
            cache[key] = value
        }
    }
}

extension QueryDate {
    func toString() -> String {
        "day_\(day ?? 0)_month_\(month ?? 0)_year_\(year)"
    }
}
