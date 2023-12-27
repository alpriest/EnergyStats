//
//  Networking.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

extension URL {
    static var auth = URL(string: "https://www.foxesscloud.com/c/v0/user/login")!
    static var report = URL(string: "https://www.foxesscloud.com/c/v0/device/history/report")!
    static var raw = URL(string: "https://www.foxesscloud.com/c/v0/device/history/raw")!
    static var battery = URL(string: "https://www.foxesscloud.com/c/v0/device/battery/info")!
    static var deviceList = URL(string: "https://www.foxesscloud.com/c/v0/device/list")!
    static var socGet = URL(string: "https://www.foxesscloud.com/c/v0/device/battery/soc/get")!
    static var addressBook = URL(string: "https://www.foxesscloud.com/c/v0/device/addressbook")!
    static var variables = URL(string: "https://www.foxesscloud.com/c/v1/device/variables")!
    static var earnings = URL(string: "https://www.foxesscloud.com/c/v0/device/earnings")!
    static var socSet = URL(string: "https://www.foxesscloud.com/c/v0/device/battery/soc/set")!
    static var batteryTimes = URL(string: "https://www.foxesscloud.com/c/v0/device/battery/time/get")!
    static var batteryTimeSet = URL(string: "https://www.foxesscloud.com/c/v0/device/battery/time/set")!
    static var deviceSettings = URL(string: "https://www.foxesscloud.com/c/v0/device/setting/get")!
    static var deviceSettingsSet = URL(string: "https://www.foxesscloud.com/c/v0/device/setting/set")!
    static var moduleList = URL(string: "https://www.foxesscloud.com/c/v0/module/list")!
    static var errorMessages = URL(string: "https://www.foxesscloud.com/c/v0/errors/message")!
}

public protocol FoxESSNetworking {
//    func ensureHasToken() async
//    func verifyCredentials(username: String, hashedPassword: String) async throws
//    func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [ReportResponse]
//    func fetchBattery(deviceID: String) async throws -> BatteryResponse
//    func fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse
//    func fetchRaw(deviceID: String, variables: [RawVariable], queryDate: QueryDate) async throws -> [RawResponse]
//    func fetchDeviceList() async throws -> [PagedDeviceListResponse.Device]
//    func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse
//    func fetchVariables(deviceID: String) async throws -> [RawVariable]
//    func fetchEarnings(deviceID: String) async throws -> EarningsResponse
//    func setSoc(minGridSOC: Int, minSOC: Int, deviceSN: String) async throws
//    func fetchBatteryTimes(deviceSN: String) async throws -> BatteryTimesResponse
//    func setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws
//    func fetchWorkMode(deviceID: String) async throws -> DeviceSettingsGetResponse
//    func setWorkMode(deviceID: String, workMode: InverterWorkMode) async throws
//    func fetchDataLoggers() async throws -> PagedDataLoggerListResponse
//
//    func fetchSchedulerFlag(deviceSN: String) async throws -> SchedulerFlagResponse
//    func fetchScheduleModes(deviceID: String) async throws -> [SchedulerModeResponse]
//    func fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleListResponse
//    func saveSchedule(deviceSN: String, schedule: Schedule) async throws
//    func saveScheduleTemplate(deviceSN: String, template: ScheduleTemplate) async throws
//    func deleteSchedule(deviceSN: String) async throws
//    func createScheduleTemplate(name: String, description: String) async throws
//    func fetchScheduleTemplates() async throws -> ScheduleTemplateListResponse
//    func enableScheduleTemplate(deviceSN: String, templateID: String) async throws
//    func fetchScheduleTemplate(deviceSN: String, templateID: String) async throws -> ScheduleTemplateResponse
//    func deleteScheduleTemplate(templateID: String) async throws

    func fetchErrorMessages() async

    // Open API
    func openapi_fetchVariables() async throws -> [OpenApiVariable]
    func openapi_fetchDeviceList() async throws -> [String]
    func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse
    func openapi_fetchHistory(deviceSN: String, variables: [String]) async throws -> OpenHistoryResponse
}
