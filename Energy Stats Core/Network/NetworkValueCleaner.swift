//
//  NetworkValueCleaner.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 20/10/2023.
//

import Foundation

public class NetworkValueCleaner: FoxESSNetworking {
    private let network: FoxESSNetworking
    private let appSettingsPublisher: LatestAppSettingsPublisher

    public init(network: FoxESSNetworking, appSettingsPublisher: LatestAppSettingsPublisher) {
        self.network = network
        self.appSettingsPublisher = appSettingsPublisher
    }

    public func deleteScheduleTemplate(templateID: String) async throws {
        try await network.deleteScheduleTemplate(templateID: templateID)
    }

    public func saveScheduleTemplate(deviceSN: String, template: ScheduleTemplate) async throws {
        try await network.saveScheduleTemplate(deviceSN: deviceSN, template: template)
    }

    public func fetchScheduleTemplate(deviceSN: String, templateID: String) async throws -> ScheduleTemplateResponse {
        try await network.fetchScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
    }

    public func enableScheduleTemplate(deviceSN: String, templateID: String) async throws {
        try await network.enableScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
    }

    public func fetchScheduleTemplates() async throws -> ScheduleTemplateListResponse {
        try await network.fetchScheduleTemplates()
    }

    public func createScheduleTemplate(name: String, description: String) async throws {
        try await network.createScheduleTemplate(name: name, description: description)
    }

    public func deleteSchedule(deviceSN: String) async throws {
        try await network.deleteSchedule(deviceSN: deviceSN)
    }

    public func saveSchedule(deviceSN: String, schedule: Schedule) async throws {
        try await network.saveSchedule(deviceSN: deviceSN, schedule: schedule)
    }

    public func fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleListResponse {
        try await network.fetchCurrentSchedule(deviceSN: deviceSN)
    }

    public func fetchScheduleModes(deviceID: String) async throws -> [SchedulerModeResponse] {
        try await network.fetchScheduleModes(deviceID: deviceID)
    }

    public func fetchSchedulerFlag(deviceSN: String) async throws -> SchedulerFlagResponse {
        try await network.fetchSchedulerFlag(deviceSN: deviceSN)
    }

    public func openapi_fetchBatterySettings(deviceSN: String) async throws -> BatterySOCResponse {
        try await network.openapi_fetchBatterySettings(deviceSN: deviceSN)
    }

    public func openapi_fetchDeviceList() async throws -> [DeviceDetailResponse] {
        try await network.openapi_fetchDeviceList()
    }

    public func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {
        try await network.openapi_setBatterySoc(deviceSN: deviceSN, minSOCOnGrid: minSOCOnGrid, minSOC: minSOC)
    }

    public func openapi_fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime] {
        try await network.openapi_fetchBatteryTimes(deviceSN: deviceSN)
    }

    public func openapi_setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {
        try await network.openapi_setBatteryTimes(deviceSN: deviceSN, times: times)
    }

    public func openapi_fetchDataLoggers() async throws -> [DataLoggerResponse] {
        try await network.openapi_fetchDataLoggers()
    }

    public func fetchErrorMessages() async {
        await network.fetchErrorMessages()
    }

    public func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        let original = try await network.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)

        return OpenQueryResponse(time: original.time, deviceSN: deviceSN, datas: original.datas.map { originalData in
            OpenQueryResponse.Data(unit: originalData.unit,
                                   variable: originalData.variable,
                                   value: originalData.value.capped(appSettingsPublisher.value.dataCeiling))
        })
    }

    public func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        let original = try await network.openapi_fetchHistory(deviceSN: deviceSN, variables: variables, start: start, end: end)

        return OpenHistoryResponse(deviceSN: original.deviceSN, datas: original.datas.map { originalData in
            OpenHistoryResponse.Data(unit: originalData.unit,
                                     name: originalData.name,
                                     variable: originalData.variable,
                                     data: originalData.data.map {
                                         OpenHistoryResponse.Data.UnitData(time: $0.time, value: $0.value.capped(appSettingsPublisher.value.dataCeiling))
                                     })
        })
    }

    public func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        try await network.openapi_fetchVariables()
    }

    public func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        try await network.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)
    }
}

extension Double {
    func capped(_ ceiling: DataCeiling) -> Double {
        guard self > 0 else { return self }

        let register = Int(self * 10)
        let mask = switch ceiling {
        case .none:
            0x0
        case .mild:
            0xfff00000
        case .enhanced:
            0xffff0000
        }

        let masked = register & mask
        if masked == 0 {
            return self
        } else {
            return self - (Double(masked) / 10.0).rounded(decimalPlaces: 3)
        }
    }
}
