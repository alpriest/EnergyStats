//
//  Network+OpenAPI+Schedule.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 19/01/2024.
//

import Foundation

extension URL {
    static let getOpenSchedulerFlag = URL(string: "https://www.foxesscloud.com/op/v1/device/scheduler/get/flag")!
    static let getOpenCurrentSchedule = URL(string: "https://www.foxesscloud.com/op/v1/device/scheduler/get")!
    static let setOpenSchedulerFlag = URL(string: "https://www.foxesscloud.com/op/v1/device/scheduler/set/flag")!
    static let setOpenCurrentSchedule = URL(string: "https://www.foxesscloud.com/op/v1/device/scheduler/enable")!
}

extension FoxAPIService {
    func openapi_fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        var request = URLRequest(url: URL.getOpenSchedulerFlag)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(GetSchedulerFlagRequest(deviceSN: deviceSN))

        let result: (GetSchedulerFlagResponse, Data) = try await fetch(request)
        return result.0
    }

    func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleResponse {
        var request = URLRequest(url: URL.getOpenCurrentSchedule)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(GetCurrentSchedulerRequest(deviceSN: deviceSN))

        let result: (ScheduleResponse, Data) = try await fetch(request)
        return result.0
    }

    func openapi_setScheduleFlag(deviceSN: String, enable: Bool) async throws {
        var request = URLRequest(url: URL.setOpenSchedulerFlag)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(SetSchedulerFlagRequest(deviceSN: deviceSN, enable: enable.intValue))

        do {
            let _: (String, Data) = try await fetch(request)
        } catch let NetworkError.invalidResponse(_, statusCode) where statusCode == 200 {
            // Ignore
        }
    }

    func openapi_saveSchedule(deviceSN: String, schedule: Schedule) async throws {
        var request = URLRequest(url: URL.setOpenCurrentSchedule)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(SetCurrentScheduleRequest(deviceSN: deviceSN, groups: schedule.phases.map { $0.toPhaseResponse() }))

        do {
            let _: (String, Data) = try await fetch(request)
        } catch let NetworkError.invalidResponse(_, statusCode) where statusCode == 200 {
            // Ignore
        }
    }
}

extension SchedulePhase {
    func toPhaseResponse() -> SchedulePhaseNetworkModel {
        SchedulePhaseNetworkModel(
            enable: true.intValue,
            startHour: start.hour,
            startMinute: start.minute,
            endHour: end.hour,
            endMinute: end.minute,
            workMode: mode,
            minSocOnGrid: minSocOnGrid,
            fdSoc: forceDischargeSOC,
            fdPwr: forceDischargePower,
            maxSoc: maxSOC
        )
    }
}
