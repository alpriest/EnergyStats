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
    private let isDemoUserProvider: () -> Bool
    private let store: KeychainStoring
    private let throttler = ThrottleManager()
    private let writeAPIkey = "writeable-method" // All inverter write methods must delay 2s between each call, so use a shared key

    init(api: FoxAPIServicing, isDemoUser provider: @escaping () -> Bool, store: KeychainStoring) {
        self.api = api
        self.demoAPI = DemoAPI()
        self.isDemoUserProvider = provider
        self.store = store
    }

    private var isDemoUser: Bool {
        isDemoUserProvider() || store.isDemoUser
    }

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
            defer {
                throttler.didInvoke(method: writeAPIkey)
            }
            try await throttler.throttle(method: writeAPIkey, minimumDuration: 2.0)
            try await api.openapi_setScheduleFlag(deviceSN: deviceSN, enable: enable)
        }
    }

    func openapi_fetchBatterySoc(deviceSN: String) async throws -> BatterySOCResponse {
        return if isDemoUser {
            try await demoAPI.openapi_fetchBatterySoc(deviceSN: deviceSN)
        } else {
            try await api.openapi_fetchBatterySoc(deviceSN: deviceSN)
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
        if isDemoUser {
            return try await demoAPI.openapi_setBatterySoc(deviceSN: deviceSN, minSOCOnGrid: minSOCOnGrid, minSOC: minSOC)
        } else {
            defer {
                throttler.didInvoke(method: writeAPIkey)
            }
            try await throttler.throttle(method: writeAPIkey, minimumDuration: 2.0)
            return try await api.openapi_setBatterySoc(deviceSN: deviceSN, minSOCOnGrid: minSOCOnGrid, minSOC: minSOC)
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
        if isDemoUser {
            return try await demoAPI.openapi_setBatteryTimes(deviceSN: deviceSN, times: times)
        } else {
            defer {
                throttler.didInvoke(method: writeAPIkey)
            }
            try await throttler.throttle(method: writeAPIkey, minimumDuration: 2.0)
            return try await api.openapi_setBatteryTimes(deviceSN: deviceSN, times: times)
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
            defer {
                throttler.didInvoke(method: writeAPIkey)
            }
            try await throttler.throttle(method: writeAPIkey, minimumDuration: 2.0)
            try await api.openapi_saveSchedule(deviceSN: deviceSN, schedule: schedule)
        }
    }

    func openapi_fetchPowerStationList() async throws -> PagedPowerStationListResponse {
        if isDemoUser {
            try await demoAPI.openapi_fetchPowerStationList()
        } else {
            try await api.openapi_fetchPowerStationList()
        }
    }

    func openapi_fetchPowerStationDetail(stationID: String) async throws -> PowerStationDetailResponse {
        if isDemoUser {
            try await demoAPI.openapi_fetchPowerStationDetail(stationID: stationID)
        } else {
            try await api.openapi_fetchPowerStationDetail(stationID: stationID)
        }
    }

    func openapi_fetchRequestCount() async throws -> ApiRequestCountResponse {
        if isDemoUser {
            try await demoAPI.openapi_fetchRequestCount()
        } else {
            try await api.openapi_fetchRequestCount()
        }
    }

    func openapi_fetchDeviceSettingsItem(deviceSN: String, item: DeviceSettingsItem) async throws -> FetchDeviceSettingsItemResponse {
        if isDemoUser {
            try await demoAPI.openapi_fetchDeviceSettingsItem(deviceSN: deviceSN, item: item)
        } else {
            try await api.openapi_fetchDeviceSettingsItem(deviceSN: deviceSN, item: item)
        }
    }

    func openapi_setDeviceSettingsItem(deviceSN: String, item: DeviceSettingsItem, value: String) async throws {
        if isDemoUser {
            try await demoAPI.openapi_setDeviceSettingsItem(deviceSN: deviceSN, item: item, value: value)
        } else {
            try await api.openapi_setDeviceSettingsItem(deviceSN: deviceSN, item: item, value: value)
        }
    }
}

class ThrottleManager {
    private var lastCallTimes: [String: Date] = [:]
    private let queue = DispatchQueue(label: "throttle-manager-queue", qos: .utility)

    func throttle(method: String, minimumDuration: TimeInterval = 1.0) async throws {
        guard let lastCallTime = lastCallTime(for: method) else {
            didInvoke(method: method)
            return
        }

        let now = Date()
        let timeSinceLastCall = now.timeIntervalSince(lastCallTime)

        if timeSinceLastCall < minimumDuration {
            let waitTime = UInt64((minimumDuration - timeSinceLastCall) * 1_000_000_000) // Convert seconds to nanoseconds
            try await Task.sleep(nanoseconds: waitTime)
        }
    }

    func lastCallTime(for method: String) -> Date? {
        queue.sync {
            self.lastCallTimes[method]
        }
    }

    func didInvoke(method: String) {
        queue.sync {
            lastCallTimes[method] = Date()
        }
    }
}
