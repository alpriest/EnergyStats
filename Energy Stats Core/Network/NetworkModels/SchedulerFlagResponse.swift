//
//  SchedulerFlagResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 30/11/2023.
//

import Foundation

public struct SchedulerFlagResponse: Decodable {
    public let enable: Bool
    public let support: Bool
}

public struct SchedulerModesResponse: Decodable {
    public let modes: [SchedulerModeResponse]
}

public struct SchedulerModeResponse: Decodable, Hashable {
    public let color: String
    public let name: String
    public let key: String

    public init(color: String, name: String, key: String) {
        self.color = color
        self.name = name
        self.key = key
    }
}

public struct ScheduleListResponse: Decodable {
    public let data: [ScheduleMetadataResponse]
    public let enable: Bool
    public let pollcy: [SchedulePollcy]
}

public struct ScheduleMetadataResponse: Decodable {
    public let templateName: String
    public let enable: Bool
    public let templateID: String
}

public struct SchedulePollcy: Codable {
    public let startH: Int
    public let endH: Int
    public let startM: Int
    public let endM: Int
    public let fdpwr: Int
    public let workMode: String
    public let fdsoc: Int
    public let minsocongrid: Int
}

public struct ScheduleSaveRequest: Encodable {
    public let pollcy: [SchedulePollcy]
    public let deviceSN: String
}