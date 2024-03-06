//
//  NetworkValueCleaner.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 20/10/2023.
//

import Foundation

class NetworkValueCleaner: FoxAPIServicing {
    private let api: FoxAPIServicing
    private let appSettingsPublisher: LatestAppSettingsPublisher

    init(api: FoxAPIServicing, appSettingsPublisher: LatestAppSettingsPublisher) {
        self.api = api
        self.appSettingsPublisher = appSettingsPublisher
    }

    //     func deleteScheduleTemplate(templateID: String) async throws {
    //        try await network.deleteScheduleTemplate(templateID: templateID)
    //    }
    //
    //     func saveScheduleTemplate(deviceSN: String, template: ScheduleTemplate) async throws {
    //        try await network.saveScheduleTemplate(deviceSN: deviceSN, template: template)
    //    }
    //
    //     func fetchScheduleTemplate(deviceSN: String, templateID: String) async throws -> ScheduleTemplateResponse {
    //        try await network.fetchScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
    //    }
    //
    //     func enableScheduleTemplate(deviceSN: String, templateID: String) async throws {
    //        try await network.enableScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
    //    }
    //
    //     func fetchScheduleTemplates() async throws -> ScheduleTemplateListResponse {
    //        try await network.fetchScheduleTemplates()
    //    }
    //
    //     func createScheduleTemplate(name: String, description: String) async throws {
    //        try await network.createScheduleTemplate(name: name, description: description)
    //    }
    //
    //     func deleteSchedule(deviceSN: String) async throws {
    //        try await network.deleteSchedule(deviceSN: deviceSN)
    //    }
    //
    //     func saveSchedule(deviceSN: String, schedule: Schedule) async throws {
    //        try await network.saveSchedule(deviceSN: deviceSN, schedule: schedule)
    //    }
    //
    //     func fetchScheduleModes(deviceID: String) async throws -> [SchedulerModeResponse] {
    //        try await network.fetchScheduleModes(deviceID: deviceID)
    //    }

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
        try await api.openapi_fetchDeviceList()
    }

    func openapi_fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse {
        try await api.openapi_fetchDevice(deviceSN: deviceSN)
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

    func fetchErrorMessages() async {
        await api.fetchErrorMessages()
    }

    func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        let original = try await api.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)

        return OpenQueryResponse(time: original.time, deviceSN: deviceSN, datas: original.datas.map { originalData in
            OpenQueryResponse.Data(unit: originalData.unit,
                                   variable: originalData.variable,
                                   value: originalData.value.capped(appSettingsPublisher.value.dataCeiling))
        })
    }

    func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        let original = try await api.openapi_fetchHistory(deviceSN: deviceSN, variables: variables, start: start, end: end)

        return OpenHistoryResponse(deviceSN: original.deviceSN, datas: original.datas.map { originalData in
            OpenHistoryResponse.Data(unit: originalData.unit,
                                     name: originalData.name,
                                     variable: originalData.variable,
                                     data: originalData.data.map {
                                         OpenHistoryResponse.Data.UnitData(time: $0.time, value: $0.value.capped(appSettingsPublisher.value.dataCeiling))
                                     })
        })
    }

    func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        try await api.openapi_fetchVariables()
    }

    func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        let original = try await api.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)

        return original.map {
            OpenReportResponse(
                variable: $0.variable,
                unit: $0.unit,
                values: $0.values.compactMap {
                    OpenReportResponse.ReportData(
                        index: $0.index,
                        value: $0.value.capped(appSettingsPublisher.value.dataCeiling)
                    )
                }
            )
        }
    }

    func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        try await api.openapi_fetchCurrentSchedule(deviceSN: deviceSN)
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
