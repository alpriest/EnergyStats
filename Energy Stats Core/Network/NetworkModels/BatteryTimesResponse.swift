//
//  BatteryTimesResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 27/07/2023.
//

import Foundation

public struct BatteryTimesResponse: Decodable {
    let sn: String
    public let times: [ChargeTime]
}

public struct ChargeTime: Codable {
    var enableCharge = true
    public let enableGrid: Bool
    public let startTime: Time
    public let endTime: Time

    public init(enableGrid: Bool, startTime: Time, endTime: Time) {
        self.enableGrid = enableGrid
        self.startTime = startTime
        self.endTime = endTime
    }
}

public struct Time: Codable, Equatable {
    public let hour: Int
    public let minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
}

public struct SetBatteryTimesRequest: Encodable {
    let sn: String
    public let times: [ChargeTime]
}
