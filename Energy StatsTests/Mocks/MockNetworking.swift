//
//  MockNetworking.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

@testable import Energy_Stats
@testable import Energy_Stats_Core
import Foundation

class MockNetworking: Networking {
    private let throwOnCall: Bool
    private let dateProvider: () -> Date

    init(throwOnCall: Bool = false, dateProvider: @escaping () -> Date = { Date() }) {
        self.throwOnCall = throwOnCall
        self.dateProvider = dateProvider
    }

    func fetchErrorMessages() async {}

    private func rawData() throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: "raw-success", withExtension: "json") else {
            return Data()
        }

        return try Data(contentsOf: url)
    }

    func fetchDeviceList() async throws -> [DeviceSummaryResponse] {
        []
    }

    func fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse {
        DeviceDetailResponse(deviceSN: "", moduleSN: "", stationID: "", stationName: "", managerVersion: "", masterVersion: "", slaveVersion: "", hardwareVersion: "", status: 0, function: DeviceDetailResponse.Function(scheduler: false), productType: "", deviceType: "", hasBattery: false, hasPV: false)
    }

    func fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        OpenQueryResponse(time: Date(), deviceSN: "", datas: [])
    }

    func fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        OpenHistoryResponse(deviceSN: "", datas: [])
    }

    func fetchVariables() async throws -> [OpenApiVariable] {
        []
    }

    func fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        []
    }

    func fetchBatterySettings(deviceSN: String) async throws -> BatterySOCResponse {
        BatterySOCResponse(minSocOnGrid: 0, minSoc: 0)
    }

    func setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {}

    func setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {}

    func fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime] {
        [ChargeTime(enable: false, startTime: Time(hour: 01, minute: 00), endTime: Time(hour: 01, minute: 30)),
         ChargeTime(enable: false, startTime: Time(hour: 03, minute: 00), endTime: Time(hour: 03, minute: 30))]
    }

    func fetchDataLoggers() async throws -> [DataLoggerResponse] {
        [
            DataLoggerResponse(moduleSN: "ABC123DEF456", stationID: "John Doe 1", status: .online, signal: 3),
            DataLoggerResponse(moduleSN: "123DEF456ABC", stationID: "Jane Doe 2", status: .online, signal: 1)
        ]
    }

    func fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        GetSchedulerFlagResponse(enable: true, support: true)
    }

    func fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        ScheduleResponse(enable: true.intValue, groups: [])
    }

    func setScheduleFlag(deviceSN: String, enable: Bool) async throws {}

    func saveSchedule(deviceSN: String, schedule: Schedule) async throws {}

    func fetchPowerStationDetail() async throws -> PowerStationDetail? {
        nil
    }
}
