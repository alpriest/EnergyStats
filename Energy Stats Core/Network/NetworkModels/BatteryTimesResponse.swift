//
//  BatteryTimesResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 27/07/2023.
//

import Foundation

public struct BatteryTimesResponse: Decodable {
    public let times: [ChargeTime]
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

public struct SetBatteryTimesRequest: Encodable {
    let sn: String
    public let times: [ChargeTime]
}
