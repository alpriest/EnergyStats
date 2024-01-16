//
//  NetworkFacade.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/10/2022.
//

import Foundation

public class NetworkFacade: FoxESSNetworking {
    private let network: FoxESSNetworking
    private let fakeNetwork: FoxESSNetworking
    private let config: Config
    private let store: KeychainStoring
    private let throttler = ThrottleManager()

    public init(network: FoxESSNetworking, config: Config, store: KeychainStoring) {
        self.network = network
        self.fakeNetwork = DemoNetworking()
        self.config = config
        self.store = store
    }

    private var isDemoUser: Bool {
        config.isDemoUser || store.isDemoUser
    }

    public func deleteScheduleTemplate(templateID: String) async throws {
        if isDemoUser {
            try await fakeNetwork.deleteScheduleTemplate(templateID: templateID)
        } else {
            try await network.deleteScheduleTemplate(templateID: templateID)
        }
    }

    public func fetchScheduleTemplate(deviceSN: String, templateID: String) async throws -> ScheduleTemplateResponse {
        if isDemoUser {
            try await fakeNetwork.fetchScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
        } else {
            try await network.fetchScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
        }
    }

    public func enableScheduleTemplate(deviceSN: String, templateID: String) async throws {
        if isDemoUser {
            try await fakeNetwork.enableScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
        } else {
            try await network.enableScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
        }
    }

    public func fetchScheduleTemplates() async throws -> ScheduleTemplateListResponse {
        if isDemoUser {
            try await fakeNetwork.fetchScheduleTemplates()
        } else {
            try await network.fetchScheduleTemplates()
        }
    }

    public func createScheduleTemplate(name: String, description: String) async throws {
        if isDemoUser {
            try await fakeNetwork.createScheduleTemplate(name: name, description: description)
        } else {
            try await network.createScheduleTemplate(name: name, description: description)
        }
    }

    public func deleteSchedule(deviceSN: String) async throws {
        if isDemoUser {
            try await fakeNetwork.deleteSchedule(deviceSN: deviceSN)
        } else {
            try await network.deleteSchedule(deviceSN: deviceSN)
        }
    }

    public func saveSchedule(deviceSN: String, schedule: Schedule) async throws {
        if isDemoUser {
            try await fakeNetwork.saveSchedule(deviceSN: deviceSN, schedule: schedule)
        } else {
            try await network.saveSchedule(deviceSN: deviceSN, schedule: schedule)
        }
    }

    public func saveScheduleTemplate(deviceSN: String, template: ScheduleTemplate) async throws {
        if isDemoUser {
            try await fakeNetwork.saveScheduleTemplate(deviceSN: deviceSN, template: template)
        } else {
            try await network.saveScheduleTemplate(deviceSN: deviceSN, template: template)
        }
    }

    public func fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleListResponse {
        if isDemoUser {
            try await fakeNetwork.fetchCurrentSchedule(deviceSN: deviceSN)
        } else {
            try await network.fetchCurrentSchedule(deviceSN: deviceSN)
        }
    }

    public func fetchScheduleModes(deviceID: String) async throws -> [SchedulerModeResponse] {
        if isDemoUser {
            try await fakeNetwork.fetchScheduleModes(deviceID: deviceID)
        } else {
            try await network.fetchScheduleModes(deviceID: deviceID)
        }
    }

    public func fetchSchedulerFlag(deviceSN: String) async throws -> SchedulerFlagResponse {
        if isDemoUser {
            try await fakeNetwork.fetchSchedulerFlag(deviceSN: deviceSN)
        } else {
            try await network.fetchSchedulerFlag(deviceSN: deviceSN)
        }
    }

    public func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [ReportResponse] {
        return if isDemoUser {
            try await fakeNetwork.fetchReport(deviceID: deviceID, variables: variables, queryDate: queryDate, reportType: reportType)
        } else {
            try await network.fetchReport(deviceID: deviceID, variables: variables, queryDate: queryDate, reportType: reportType)
        }
    }

    public func fetchBattery(deviceID: String) async throws -> BatteryResponse {
        return if isDemoUser {
            try await fakeNetwork.fetchBattery(deviceID: deviceID)
        } else {
            try await network.fetchBattery(deviceID: deviceID)
        }
    }

    public func openapi_fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse {
        return if isDemoUser {
            try await fakeNetwork.openapi_fetchBatterySettings(deviceSN: deviceSN)
        } else {
            try await network.openapi_fetchBatterySettings(deviceSN: deviceSN)
        }
    }

    public func fetchRaw(deviceID: String, variables: [RawVariable], queryDate: QueryDate) async throws -> [RawResponse] {
        return if isDemoUser {
            try await fakeNetwork.fetchRaw(deviceID: deviceID, variables: variables, queryDate: queryDate)
        } else {
            try await network.fetchRaw(deviceID: deviceID, variables: variables, queryDate: queryDate)
        }
    }

    public func openapi_fetchDeviceList() async throws -> [DeviceDetailResponse] {
        return if isDemoUser {
            try await fakeNetwork.openapi_fetchDeviceList()
        } else {
            try await network.openapi_fetchDeviceList()
        }
    }

    public func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse {
        return if isDemoUser {
            try await fakeNetwork.fetchAddressBook(deviceID: deviceID)
        } else {
            try await network.fetchAddressBook(deviceID: deviceID)
        }
    }

    public func fetchVariables(deviceID: String) async throws -> [RawVariable] {
        return if isDemoUser {
            try await fakeNetwork.fetchVariables(deviceID: deviceID)
        } else {
            try await network.fetchVariables(deviceID: deviceID)
        }
    }

    public func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {
        return if isDemoUser {
            try await fakeNetwork.openapi_setBatterySoc(deviceSN: deviceSN, minSOCOnGrid: minSOCOnGrid, minSOC: minSOC)
        } else {
            try await network.openapi_setBatterySoc(deviceSN: deviceSN, minSOCOnGrid: minSOCOnGrid, minSOC: minSOC)
        }
    }

    public func fetchBatteryTimes(deviceSN: String) async throws -> BatteryTimesResponse {
        return if isDemoUser {
            try await fakeNetwork.fetchBatteryTimes(deviceSN: deviceSN)
        } else {
            try await network.fetchBatteryTimes(deviceSN: deviceSN)
        }
    }

    public func setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {
        return if isDemoUser {
            try await fakeNetwork.setBatteryTimes(deviceSN: deviceSN, times: times)
        } else {
            try await network.setBatteryTimes(deviceSN: deviceSN, times: times)
        }
    }

    public func fetchWorkMode(deviceID: String) async throws -> DeviceSettingsGetResponse {
        return if isDemoUser {
            try await fakeNetwork.fetchWorkMode(deviceID: deviceID)
        } else {
            try await network.fetchWorkMode(deviceID: deviceID)
        }
    }

    public func setWorkMode(deviceID: String, workMode: InverterWorkMode) async throws {
        return if isDemoUser {
            try await fakeNetwork.setWorkMode(deviceID: deviceID, workMode: workMode)
        } else {
            try await network.setWorkMode(deviceID: deviceID, workMode: workMode)
        }
    }

    public func fetchDataLoggers() async throws -> PagedDataLoggerListResponse {
        return if isDemoUser {
            try await fakeNetwork.fetchDataLoggers()
        } else {
            try await network.fetchDataLoggers()
        }
    }

    public func fetchErrorMessages() async {
        if isDemoUser {
            await fakeNetwork.fetchErrorMessages()
        } else {
            await network.fetchErrorMessages()
        }
    }

    public func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        if isDemoUser {
            return try await fakeNetwork.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
        } else {
            defer {
                throttler.didInvoke(method: #function)
            }
            try await throttler.throttle(method: #function)
            return try await network.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
        }
    }

    public func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        if isDemoUser {
            return try await fakeNetwork.openapi_fetchHistory(deviceSN: deviceSN, variables: variables, start: start, end: end)
        } else {
            defer {
                throttler.didInvoke(method: #function)
            }
            try await throttler.throttle(method: #function)
            return try await network.openapi_fetchHistory(deviceSN: deviceSN, variables: variables, start: start, end: end)
        }
    }

    public func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        if isDemoUser {
            return try await fakeNetwork.openapi_fetchVariables()
        } else {
            defer {
                throttler.didInvoke(method: #function)
            }
            try await throttler.throttle(method: #function)
            return try await network.openapi_fetchVariables()
        }
    }

    public func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        if isDemoUser {
            return try await fakeNetwork.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)
        } else {
            defer {
                throttler.didInvoke(method: #function)
            }
            try await throttler.throttle(method: #function)
            return try await network.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)
        }
    }
}

class ThrottleManager {
    private var lastCallTimes: [String: Date] = [:]

    func throttle(method: String) async throws {
        guard let lastCallTime = lastCallTimes[method] else {
            lastCallTimes[method] = Date()
            return
        }

        let now = Date()
        let timeSinceLastCall = now.timeIntervalSince(lastCallTime)

        if timeSinceLastCall < 1.0 {
            let waitTime = UInt64((1.0 - timeSinceLastCall) * 1_000_000_000) // Convert seconds to nanoseconds
            try await Task.sleep(nanoseconds: waitTime)
        }
    }

    func didInvoke(method: String) {
        lastCallTimes[method] = Date()
    }
}
