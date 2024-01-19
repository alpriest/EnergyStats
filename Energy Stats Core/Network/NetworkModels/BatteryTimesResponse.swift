//
//  BatteryTimesResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 27/07/2023.
//

import Foundation

public struct BatteryTimesResponse: Decodable {
    public let enable1: Bool
    public let startTime1: Time
    public let endTime1: Time

    public let enable2: Bool
    public let startTime2: Time
    public let endTime2: Time
}

public struct SetBatteryTimesRequest: Encodable {
    let sn: String

    let enable1: Bool
    let startTime1: Time
    let endTime1: Time

    let enable2: Bool
    let startTime2: Time
    let endTime2: Time
}

public struct ChargeTime: Codable {
    public let enable: Bool
    public let startTime: Time
    public let endTime: Time

    public init(enable: Bool, startTime: Time, endTime: Time) {
        self.enable = enable
        self.startTime = startTime
        self.endTime = endTime
    }
}
