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
}

public extension Network {
    func openapi_fetchSchedulerFlag(deviceSN: String) async throws -> SchedulerFlagResponse {
        var request = URLRequest(url: URL.getOpenSchedulerFlag)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(SchedulerFlagRequest(deviceSN: deviceSN))

        let result: (SchedulerFlagResponse, Data) = try await fetch(request)
        return result.0
    }

    func openapi_fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleDetailListResponse {
        var request = URLRequest(url: URL.getOpenCurrentSchedule)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(GetCurrentSchedulerRequest(deviceSN: deviceSN))

        let result: (ScheduleDetailListResponse, Data) = try await fetch(request)
        return result.0
    }
}
