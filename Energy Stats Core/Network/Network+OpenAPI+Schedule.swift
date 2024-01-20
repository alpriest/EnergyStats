//
//  Network+OpenAPI+Schedule.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 19/01/2024.
//

import Foundation

extension URL {
    static var getOpenSchedulerFlag = URL(string: "https://www.foxesscloud.com/op/v0/device/scheduler/get/flag")!
    static var getOpenCurrentSchedule = URL(string: "https://www.foxesscloud.com/op/v0/device/scheduler/get")!
    static var setOpenSchedulerFlag = URL(string: "https://www.foxesscloud.com/op/v0/device/scheduler/set/flag")!
}

public extension Network {
    func openapi_fetchSchedulerFlag(deviceSN: String) async throws -> GetSchedulerFlagResponse {
        var request = URLRequest(url: URL.getOpenSchedulerFlag)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(GetSchedulerFlagRequest(deviceSN: deviceSN))

        let result: (GetSchedulerFlagResponse, Data) = try await fetch(request)
        return result.0
    }

    func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleDetailListResponse {
        var request = URLRequest(url: URL.getOpenCurrentSchedule)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(GetCurrentSchedulerRequest(deviceSN: deviceSN))

        let result: (ScheduleDetailListResponse, Data) = try await fetch(request)
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
}
