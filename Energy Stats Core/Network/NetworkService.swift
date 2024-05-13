//
//  NetworkService.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/03/2024.
//

import Foundation

public protocol Networking {
    func fetchErrorMessages() async
    func fetchDeviceList() async throws -> [DeviceSummaryResponse]
    func fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse
    func fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse
    func fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse
    func fetchVariables() async throws -> [OpenApiVariable]
    func fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse]
    func fetchBatterySettings(deviceSN: String) async throws -> BatterySOCResponse
    func setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws
    func fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime]
    func setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws
    func fetchDataLoggers() async throws -> [DataLoggerResponse]
    func fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse
    func fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse
    func setScheduleFlag(deviceSN: String, enable: Bool) async throws
    func saveSchedule(deviceSN: String, schedule: Schedule) async throws
    func fetchPowerStationDetail() async throws -> PowerStationDetail?
}

public class NetworkService: Networking {
    let api: FoxAPIServicing

    public static func standard(keychainStore: KeychainStoring,
                                isDemoUser: @escaping () -> Bool,
                                dataCeiling: @escaping () -> DataCeiling) -> Networking
    {
        let api = NetworkValueCleaner(
            api: NetworkFacade(
                api: NetworkCache(api: FoxAPIService(credentials: keychainStore, store: InMemoryLoggingNetworkStore.shared)),
                isDemoUser: isDemoUser,
                store: keychainStore
            ),
            dataCeiling: dataCeiling
        )
        return NetworkService(api: api)
    }

    init(api: FoxAPIServicing) {
        self.api = api
    }

    public func fetchErrorMessages() async {
        await api.fetchErrorMessages()
    }

    public func fetchDeviceList() async throws -> [DeviceSummaryResponse] {
        try await api.openapi_fetchDeviceList()
    }

    public func fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse {
        try await api.openapi_fetchDevice(deviceSN: deviceSN)
    }

    public func fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        try await api.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
    }

    public func fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        try await api.openapi_fetchHistory(deviceSN: deviceSN, variables: variables, start: start, end: end)
    }

    public func fetchVariables() async throws -> [OpenApiVariable] {
        try await api.openapi_fetchVariables()
    }

    public func fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        try await api.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)
    }

    public func fetchBatterySettings(deviceSN: String) async throws -> BatterySOCResponse {
        try await api.openapi_fetchBatterySettings(deviceSN: deviceSN)
    }

    public func setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {
        try await api.openapi_setBatterySoc(deviceSN: deviceSN, minSOCOnGrid: minSOCOnGrid, minSOC: minSOC)
    }

    public func fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime] {
        try await api.openapi_fetchBatteryTimes(deviceSN: deviceSN)
    }

    public func setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {
        try await api.openapi_setBatteryTimes(deviceSN: deviceSN, times: times)
    }

    public func fetchDataLoggers() async throws -> [DataLoggerResponse] {
        try await api.openapi_fetchDataLoggers()
    }

    public func fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        try await api.openapi_fetchSchedulerFlag(deviceSN: deviceSN)
    }

    public func fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        try await api.openapi_fetchCurrentSchedule(deviceSN: deviceSN)
    }

    public func setScheduleFlag(deviceSN: String, enable: Bool) async throws {
        try await api.openapi_setScheduleFlag(deviceSN: deviceSN, enable: enable)
    }

    public func saveSchedule(deviceSN: String, schedule: Schedule) async throws {
        try await api.openapi_saveSchedule(deviceSN: deviceSN, schedule: schedule)
    }

    public func fetchPowerStationDetail() async throws -> PowerStationDetail? {
        let list = try await api.openapi_fetchPowerStationList()
        if list.data.count == 1, let station = list.data.first {
            return try await api.openapi_fetchPowerStationDetail(stationID: station.stationID).toPowerStationDetail()
        } else {
            return nil
        }
    }
}

public extension NetworkService {
    static func preview(callsToThrow: Set<DemoAPIRequest> = Set()) -> Networking {
        DemoNetworking(callsToThrow: callsToThrow)
    }
}
