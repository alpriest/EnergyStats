//
//  BatteryTimesResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 27/07/2023.
//

import Foundation

public struct BatteryTimesResponse: Decodable {
    let sn: String
    public let times: [BatteryTime]
}

public struct BatteryTime: Decodable {
    var enableCharge = true
    public let enableGrid: Bool
    public let startTime: Time
    public let endTime: Time
}

public struct Time: Decodable {
    public let hour: Int
    public let minute: Int
}
