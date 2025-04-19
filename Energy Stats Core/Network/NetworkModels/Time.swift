//
//  Time.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 03/12/2023.
//

import Foundation

public enum TimeType {
    case start
    case end

    public func appendage() -> String {
        switch self {
        case .start:
            "00"
        case .end:
            "59"
        }
    }
}

public struct Time: Codable, Hashable, Equatable, Comparable {
    public let hour: Int
    public let minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    public init(fromMinutes totalMinutes: Int) {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        self.hour = hours
        self.minute = minutes
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

    public func formatted(type: TimeType?) -> String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2

        let parts: [String] = [
            formatter.string(from: NSNumber(value: hour)) ?? "",
            formatter.string(from: NSNumber(value: minute)) ?? "",
            type?.appendage() ?? nil
        ].compactMap { $0 }

        return parts.joined(separator: ":")
    }

    public func toMinutes() -> Int {
        return hour * 60 + minute
    }

    public func adding(minutes: Int) -> Time {
        let newMinutes = toMinutes() + minutes
        return Time(fromMinutes: newMinutes)
    }
}

public extension Date {
    static func zero() -> Date {
        guard let result = Calendar.current.date(bySetting: .hour, value: 0, of: .now) else { return .now }
        return Calendar.current.date(bySetting: .minute, value: 0, of: result) ?? .now
    }

    static func fromTime(_ time: Time) -> Date {
        var components = DateComponents()
        components.hour = time.hour
        components.minute = time.minute
        return Calendar.current.date(from: components) ?? .now
    }

    func toTime() -> Time {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self)

        return Time(hour: components.hour ?? 0,
                    minute: components.minute ?? 0)
    }
}

public extension Time {
    static func zero() -> Time {
        Time(hour: 0, minute: 0)
    }

    func toDate() -> Date {
        guard let startOfHour = Calendar.current.date(bySetting: .minute, value: 0, of: .now),
              let result = Calendar.current.date(bySetting: .hour, value: hour, of: startOfHour),
              let result2 = Calendar.current.date(bySetting: .minute, value: minute, of: result)
        else {
            return .now
        }

        return result2
    }
}
