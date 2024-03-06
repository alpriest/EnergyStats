//
//  Network+Schedule.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 09/12/2023.
//

import Foundation

extension URL {
    static var schedulerModes = URL(string: "https://www.foxesscloud.com/generic/v0/device/scheduler/modes/get")!
    static var getCurrentSchedule = URL(string: "https://www.foxesscloud.com/generic/v0/device/scheduler/list")!
    static var enableSchedule = URL(string: "https://www.foxesscloud.com/generic/v0/device/scheduler/enable")!
    static var saveScheduleTemplate = URL(string: "https://www.foxesscloud.com/generic/v0/device/scheduler/save")!
    static var deleteSchedule = URL(string: "https://www.foxesscloud.com/generic/v0/device/scheduler/disable")!
    static var createScheduleTemplate = URL(string: "https://www.foxesscloud.com/generic/v0/device/scheduler/create")!
    static var fetchScheduleTemplates = URL(string: "https://www.foxesscloud.com/generic/v0/device/scheduler/edit/list?templateType=2")!
    static var getSchedule = URL(string: "https://www.foxesscloud.com/generic/v0/device/scheduler/detail")!
    static var deleteScheduleTemplate = URL(string: "https://www.foxesscloud.com/generic/v0/device/scheduler/delete")!
}

extension FoxAPIService {
//    func deleteScheduleTemplate(templateID: String) async throws {
//        let request = append(
//            queryItems: [
//                URLQueryItem(name: "templateID", value: templateID),
//            ],
//            to: URL.deleteScheduleTemplate
//        )
//
//        do {
//            let _: (String, Data) = try await fetch(request)
//        } catch let NetworkError.invalidResponse(_, statusCode) where statusCode == 200 {
//            // Ignore
//        }
//    }

//    func fetchScheduleTemplate(deviceSN: String, templateID: String) async throws -> ScheduleTemplateResponse {
//        let request = append(
//            queryItems: [
//                URLQueryItem(name: "deviceSN", value: deviceSN),
//                URLQueryItem(name: "templateID", value: templateID),
//            ],
//            to: URL.getSchedule
//        )
//
//        let result: (ScheduleTemplateResponse, Data) = try await fetch(request)
//        return result.0
//    }

//    func enableScheduleTemplate(deviceSN: String, templateID: String) async throws {
//        var request = URLRequest(url: URL.enableSchedule)
//        request.httpMethod = "POST"
//        request.httpBody = try! JSONEncoder().encode(ScheduleEnableRequest(templateID: templateID, deviceSN: deviceSN))
//
//        do {
//            let _: (String, Data) = try await fetch(request)
//        } catch let NetworkError.invalidResponse(_, statusCode) where statusCode == 200 {
//            // Ignore
//        }
//    }

//    func saveScheduleTemplate(deviceSN: String, template: ScheduleTemplate) async throws {
//        var request = URLRequest(url: URL.saveScheduleTemplate)
//        request.httpMethod = "POST"
//        request.httpBody = try! JSONEncoder().encode(
//            ScheduleSaveRequest(pollcy: template.phases.map { $0.toPollcy() },
//                                templateID: template.id,
//                                deviceSN: deviceSN)
//        )
//
//        do {
//            let _: (String, Data) = try await fetch(request)
//        } catch let NetworkError.invalidResponse(_, statusCode) where statusCode == 200 {
//            // Ignore
//        }
//    }

//    func fetchScheduleTemplates() async throws -> ScheduleTemplateListResponse {
//        let request = URLRequest(url: URL.fetchScheduleTemplates)
//
//        let result: (ScheduleTemplateListResponse, Data) = try await fetch(request)
//        return result.0
//    }

//    func createScheduleTemplate(name: String, description: String) async throws {
//        var request = URLRequest(url: URL.createScheduleTemplate)
//        request.httpMethod = "POST"
//        request.httpBody = try! JSONEncoder().encode(ScheduleTemplateCreateRequest(templateName: name, content: description))
//
//        do {
//            let _: (String, Data) = try await fetch(request)
//        } catch let NetworkError.invalidResponse(_, statusCode) where statusCode == 200 {
//            // Ignore
//        }
//    }

//    func deleteSchedule(deviceSN: String) async throws {
//        let request = append(queryItems: [URLQueryItem(name: "deviceSN", value: deviceSN)], to: URL.deleteSchedule)
//
//        do {
//            let _: (String, Data) = try await fetch(request)
//        } catch let NetworkError.invalidResponse(_, statusCode) where statusCode == 200 {
//            // Ignore
//        }
//    }

//    func saveSchedule(deviceSN: String, schedule: Schedule) async throws {
//        var request = URLRequest(url: URL.enableSchedule)
//        request.httpMethod = "POST"
//        request.httpBody = try! JSONEncoder().encode(ScheduleSaveRequest(pollcy: schedule.phases.map { $0.toPollcy() }, templateID: nil, deviceSN: deviceSN))
//
//        do {
//            let _: (String, Data) = try await fetch(request)
//        } catch let NetworkError.invalidResponse(_, statusCode) where statusCode == 200 {
//            // Ignore
//        }
//    }

//    func fetchScheduleModes(deviceID: String) async throws -> [SchedulerModeResponse] {
//        let request = append(queryItems: [URLQueryItem(name: "deviceID", value: deviceID)], to: URL.schedulerModes)
//
//        let result: (SchedulerModesResponse, Data) = try await fetch(request)
//        return result.0.modes
//    }
}
