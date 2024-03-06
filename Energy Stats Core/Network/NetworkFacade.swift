//
//  NetworkFacade.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/10/2022.
//

import Foundation

class NetworkFacade: FoxAPIServicing {
    private let api: FoxAPIServicing
    private let demoAPI: FoxAPIServicing
    private let config: Config
    private let store: KeychainStoring
    private let throttler = ThrottleManager()

    init(api: FoxAPIServicing, config: Config, store: KeychainStoring) {
        self.api = api
        self.demoAPI = DemoAPI()
        self.config = config
        self.store = store
    }

    private var isDemoUser: Bool {
        config.isDemoUser || store.isDemoUser
    }

//     func deleteScheduleTemplate(templateID: String) async throws {
//        if isDemoUser {
//            try await fakeNetwork.deleteScheduleTemplate(templateID: templateID)
//        } else {
//            try await network.deleteScheduleTemplate(templateID: templateID)
//        }
//    }
//
//     func fetchScheduleTemplate(deviceSN: String, templateID: String) async throws -> ScheduleTemplateResponse {
//        if isDemoUser {
//            try await fakeNetwork.fetchScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
//        } else {
//            try await network.fetchScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
//        }
//    }
//
//     func enableScheduleTemplate(deviceSN: String, templateID: String) async throws {
//        if isDemoUser {
//            try await fakeNetwork.enableScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
//        } else {
//            try await network.enableScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
//        }
//    }
//
//     func fetchScheduleTemplates() async throws -> ScheduleTemplateListResponse {
//        if isDemoUser {
//            try await fakeNetwork.fetchScheduleTemplates()
//        } else {
//            try await network.fetchScheduleTemplates()
//        }
//    }
//
//     func createScheduleTemplate(name: String, description: String) async throws {
//        if isDemoUser {
//            try await fakeNetwork.createScheduleTemplate(name: name, description: description)
//        } else {
//            try await network.createScheduleTemplate(name: name, description: description)
//        }
//    }
//
//     func deleteSchedule(deviceSN: String) async throws {
//        if isDemoUser {
//            try await fakeNetwork.deleteSchedule(deviceSN: deviceSN)
//        } else {
//            try await network.deleteSchedule(deviceSN: deviceSN)
//        }
//    }
//
//     func saveSchedule(deviceSN: String, schedule: Schedule) async throws {
//        if isDemoUser {
//            try await fakeNetwork.saveSchedule(deviceSN: deviceSN, schedule: schedule)
//        } else {
//            try await network.saveSchedule(deviceSN: deviceSN, schedule: schedule)
//        }
//    }
//
//     func saveScheduleTemplate(deviceSN: String, template: ScheduleTemplate) async throws {
//        if isDemoUser {
//            try await fakeNetwork.saveScheduleTemplate(deviceSN: deviceSN, template: template)
//        } else {
//            try await network.saveScheduleTemplate(deviceSN: deviceSN, template: template)
//        }
//    }
//
//     func fetchScheduleModes(deviceID: String) async throws -> [SchedulerModeResponse] {
//        if isDemoUser {
//            try await fakeNetwork.fetchScheduleModes(deviceID: deviceID)
//        } else {
//            try await network.fetchScheduleModes(deviceID: deviceID)
//        }
//    }

    func openapi_fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        if isDemoUser {
            try await demoAPI.openapi_fetchSchedulerFlag(deviceSN: deviceSN)
        } else {
            try await api.openapi_fetchSchedulerFlag(deviceSN: deviceSN)
        }
    }

    func openapi_setScheduleFlag(deviceSN: String, enable: Bool) async throws {
        if isDemoUser {
            try await demoAPI.openapi_setScheduleFlag(deviceSN: deviceSN, enable: enable)
        } else {
            try await api.openapi_setScheduleFlag(deviceSN: deviceSN, enable: enable)
        }
    }

    func openapi_fetchBatterySettings(deviceSN: String) async throws -> BatterySOCResponse {
        return if isDemoUser {
            try await demoAPI.openapi_fetchBatterySettings(deviceSN: deviceSN)
        } else {
            try await api.openapi_fetchBatterySettings(deviceSN: deviceSN)
        }
    }

    func openapi_fetchDeviceList() async throws -> [DeviceSummaryResponse] {
        return if isDemoUser {
            try await demoAPI.openapi_fetchDeviceList()
        } else {
            try await api.openapi_fetchDeviceList()
        }
    }

    func openapi_fetchDevice(deviceSN: String) async throws -> DeviceDetailResponse {
        return if isDemoUser {
            try await demoAPI.openapi_fetchDevice(deviceSN: deviceSN)
        } else {
            try await api.openapi_fetchDevice(deviceSN: deviceSN)
        }
    }

    func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {
        return if isDemoUser {
            try await demoAPI.openapi_setBatterySoc(deviceSN: deviceSN, minSOCOnGrid: minSOCOnGrid, minSOC: minSOC)
        } else {
            try await api.openapi_setBatterySoc(deviceSN: deviceSN, minSOCOnGrid: minSOCOnGrid, minSOC: minSOC)
        }
    }

    func openapi_fetchBatteryTimes(deviceSN: String) async throws -> [ChargeTime] {
        return if isDemoUser {
            try await demoAPI.openapi_fetchBatteryTimes(deviceSN: deviceSN)
        } else {
            try await api.openapi_fetchBatteryTimes(deviceSN: deviceSN)
        }
    }

    func openapi_setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {
        return if isDemoUser {
            try await demoAPI.openapi_setBatteryTimes(deviceSN: deviceSN, times: times)
        } else {
            try await api.openapi_setBatteryTimes(deviceSN: deviceSN, times: times)
        }
    }

    func openapi_fetchDataLoggers() async throws -> [DataLoggerResponse] {
        return if isDemoUser {
            try await demoAPI.openapi_fetchDataLoggers()
        } else {
            try await api.openapi_fetchDataLoggers()
        }
    }

    func fetchErrorMessages() async {
        if isDemoUser {
            await demoAPI.fetchErrorMessages()
        } else {
            await api.fetchErrorMessages()
        }
    }

    func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        if isDemoUser {
            return try await demoAPI.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
        } else {
            defer {
                throttler.didInvoke(method: #function)
            }
            try await throttler.throttle(method: #function)
            return try await api.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
        }
    }

    func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        if isDemoUser {
            return try await demoAPI.openapi_fetchHistory(deviceSN: deviceSN, variables: variables, start: start, end: end)
        } else {
            defer {
                throttler.didInvoke(method: #function)
            }
            try await throttler.throttle(method: #function)
            return try await api.openapi_fetchHistory(deviceSN: deviceSN, variables: variables, start: start, end: end)
        }
    }

    func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        if isDemoUser {
            return try await demoAPI.openapi_fetchVariables()
        } else {
            defer {
                throttler.didInvoke(method: #function)
            }
            try await throttler.throttle(method: #function)
            return try await api.openapi_fetchVariables()
        }
    }

    func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        if isDemoUser {
            return try await demoAPI.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)
        } else {
            defer {
                throttler.didInvoke(method: #function)
            }
            try await throttler.throttle(method: #function)
            return try await api.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)
        }
    }

    func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        if isDemoUser {
            return try await demoAPI.openapi_fetchCurrentSchedule(deviceSN: deviceSN)
        } else {
            defer {
                throttler.didInvoke(method: #function)
            }
            try await throttler.throttle(method: #function)
            return try await api.openapi_fetchCurrentSchedule(deviceSN: deviceSN)
        }
    }

    func openapi_saveSchedule(deviceSN: String, schedule: Schedule) async throws {
        if isDemoUser {
            return try await demoAPI.openapi_saveSchedule(deviceSN: deviceSN, schedule: schedule)
        } else {
            try await api.openapi_saveSchedule(deviceSN: deviceSN, schedule: schedule)
        }
    }

    func openapi_fetchPowerStationList() async throws -> PagedStationListResponse {
        if isDemoUser {
            try await demoAPI.openapi_fetchPowerStationList()
        } else {
            try await api.openapi_fetchPowerStationList()
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
