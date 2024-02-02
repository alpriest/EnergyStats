//
//  ScheduleResponses.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 30/11/2023.
//

import Foundation

//public struct SchedulerModesResponse: Decodable {
//    public let modes: [SchedulerModeResponse]
//}

//public struct SchedulerModeResponse: Decodable, Hashable, Equatable {
//    public let color: String
//    public let name: String
//    public let key: String
//
//    public init(color: String, name: String, key: String) {
//        self.color = color
//        self.name = name
//        self.key = key
//    }
//}

//public struct ScheduleListResponse: Decodable {
//    public let data: [ScheduleTemplateSummaryResponse]
//    public let enable: Bool
//    public let pollcy: [SchedulePollcy]
//}

//public struct ScheduleTemplateSummaryResponse: Decodable {
//    public let templateName: String
//    public let enable: Bool
//    public let templateID: String
//}

//public struct ScheduleTemplateResponse: Decodable {
//    public let templateName: String
//    public let enable: Bool
//    public let pollcy: [SchedulePollcy]
//    public let content: String
//}

//public struct SchedulePollcy: Codable {
//    public let startH: Int
//    public let startM: Int
//    public let endH: Int
//    public let endM: Int
//    public let fdpwr: Int?
//    public let workMode: String
//    public let fdsoc: Int
//    public let minsocongrid: Int
//}

//public struct ScheduleSaveRequest: Encodable {
//    public let pollcy: [SchedulePollcy]?
//    public let templateID: String?
//    public let deviceSN: String
//}

//public struct ScheduleEnableRequest: Encodable {
//    public let templateID: String?
//    public let deviceSN: String
//}

//public struct ScheduleTemplateListResponse: Decodable {
//    public let data: [ScheduleTemplateSummaryResponse]
//}

//public struct ScheduleTemplateCreateRequest: Encodable {
//    public let templateType = 2 // user template type
//    public let templateName: String
//    public let content: String
//}
