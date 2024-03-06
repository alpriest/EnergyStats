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

public class NetworkCache: FoxAPIServicing {
    private let api: FoxAPIServicing
    private var cache: [String: CachedItem] = [:]
    private let shortCacheDurationInSeconds: TimeInterval = 5
    private let serialiserQueue = DispatchQueue(label: "networkcache.write.queue")

    public init(api: FoxAPIServicing) {
        self.api = api
    }

    //    public func deleteScheduleTemplate(templateID: String) async throws {
    //        try await network.deleteScheduleTemplate(templateID: templateID)
    //    }
    //
    //    public func saveScheduleTemplate(deviceSN: String, template: ScheduleTemplate) async throws {
    //        try await network.saveScheduleTemplate(deviceSN: deviceSN, template: template)
    //    }
    //
    //    public func fetchScheduleTemplate(deviceSN: String, templateID: String) async throws -> ScheduleTemplateResponse {
    //        try await network.fetchScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
    //    }
    //
    //    public func enableScheduleTemplate(deviceSN: String, templateID: String) async throws {
    //        try await network.enableScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
    //    }
    //
    //    public func fetchScheduleTemplates() async throws -> ScheduleTemplateListResponse {
    //        try await network.fetchScheduleTemplates()
    //    }
    //
    //    public func createScheduleTemplate(name: String, description: String) async throws {
    //        try await network.createScheduleTemplate(name: name, description: description)
    //    }
    //
    //    public func deleteSchedule(deviceSN: String) async throws {
    //        try await network.deleteSchedule(deviceSN: deviceSN)
    //    }
    //
    //    public func saveSchedule(deviceSN: String, schedule: Schedule) async throws {
    //        try await network.saveSchedule(deviceSN: deviceSN, schedule: schedule)
    //    }
    //
    //    public func fetchScheduleModes(deviceID: String) async throws -> [SchedulerModeResponse] {
    //        try await network.fetchScheduleModes(deviceID: deviceID)
    //    }

    public func openapi_fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        try await api.openapi_fetchSchedulerFlag(deviceSN: deviceSN)
    }

    public func openapi_setScheduleFlag(deviceSN: String, enable: Bool) async throws {
        try await api.openapi_setScheduleFlag(deviceSN: deviceSN, enable: enable)
    }

    public func openapi_fetchBatterySettings(deviceSN: String) async throws -> BatterySOCResponse {
        let key = makeKey(base: #function, arguments: deviceSN)

        if let item = cache[key], let cached = item.item as? BatterySOCResponse, item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchBatterySettings(deviceSN: deviceSN)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    public func openapi_fetchDeviceList() async throws -> [DeviceSummaryResponse] {
        let key = makeKey(base: #function)

        if let item = cache[key], let cached = item.item as? [DeviceSummaryResponse], item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchDeviceList()
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    public func openapi_fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse {
        try await api.openapi_fetchDevice(deviceSN: deviceSN)
    }

    public func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {
        try await api.openapi_setBatterySoc(deviceSN: deviceSN, minSOCOnGrid: minSOCOnGrid, minSOC: minSOC)
    }

    public func openapi_fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime] {
        try await api.openapi_fetchBatteryTimes(deviceSN: deviceSN)
    }

    public func openapi_setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {
        try await api.openapi_setBatteryTimes(deviceSN: deviceSN, times: times)
    }

    public func openapi_fetchDataLoggers() async throws -> [DataLoggerResponse] {
        try await api.openapi_fetchDataLoggers()
    }

    public func fetchErrorMessages() async {
        await api.fetchErrorMessages()
    }

    public func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        let key = makeKey(base: #function, arguments: deviceSN, variables.joined(separator: "_"))

        if let item = cache[key], let cached = item.item as? OpenQueryResponse, item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    public func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        let key = makeKey(base: #function, arguments: deviceSN, variables.joined(separator: "_"), String(start.timeIntervalSince1970), String(end.timeIntervalSince1970))

        if let item = cache[key], let cached = item.item as? OpenHistoryResponse, item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchHistory(deviceSN: deviceSN, variables: variables, start: start, end: end)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    public func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        try await api.openapi_fetchVariables()
    }

    public func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        let key = makeKey(base: #function, arguments: deviceSN, variables.map { $0.networkTitle }.joined(separator: "_"), queryDate.toString(), reportType.rawValue)

        if let item = cache[key], let cached = item.item as? [OpenReportResponse], item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await api.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    public func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        try await api.openapi_fetchCurrentSchedule(deviceSN: deviceSN)
    }

    public func openapi_saveSchedule(deviceSN: String, schedule: Schedule) async throws {
        try await api.openapi_saveSchedule(deviceSN: deviceSN, schedule: schedule)
    }

    public func openapi_fetchPowerStationList() async throws -> PagedStationListResponse {
        try await api.openapi_fetchPowerStationList()
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
