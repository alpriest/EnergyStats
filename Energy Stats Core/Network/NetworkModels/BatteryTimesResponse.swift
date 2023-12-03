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

public struct Time: Codable, Equatable, Comparable {
    public let hour: Int
    public let minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    public static func < (lhs: Time, rhs: Time) -> Bool {
        return if lhs.hour != rhs.hour {
            lhs.hour < rhs.hour
        } else {
            lhs.minute < rhs.minute
        }
    }

    public static func > (lhs: Time, rhs: Time) -> Bool {
        return if lhs.hour != rhs.hour {
            lhs.hour > rhs.hour
        } else {
            lhs.minute > rhs.minute
        }
    }

    public var formatted: String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2

        let hour = formatter.string(from: NSNumber(value: hour)) ?? ""
        let minute = formatter.string(from: NSNumber(value: minute)) ?? ""

        return "\(hour):\(minute)"
    }

    public func toMinutes() -> Int {
        return hour * 60 + minute
    }
}

public struct SetBatteryTimesRequest: Encodable {
    let sn: String
    public let times: [ChargeTime]
}
