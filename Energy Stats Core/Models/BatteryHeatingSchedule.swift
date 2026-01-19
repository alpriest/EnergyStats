//
//  BatteryHeatingSchedule.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/01/2026.
//

public struct BatteryHeatingSchedule {
    public let enabled: Bool
    public let warmUpState: String?
    public let period1Start: Time
    public let period1End: Time
    public let period1Enabled: Bool
    public let period2Start: Time
    public let period2End: Time
    public let period2Enabled: Bool
    public let period3Start: Time
    public let period3End: Time
    public let period3Enabled: Bool
    public let minStartTemperature: Double
    public let maxStartTemperature: Double
    public let minEndTemperature: Double
    public let maxEndTemperature: Double

    enum ParseError: Error {
        case missingResult
        case missingValue(String)
        case invalidInt(String, String)
        case invalidDouble(String, String)
        case invalidBool(String, String)
    }

    private static func dictionary(from response: BatteryHeatingScheduleResponse) throws -> [String: String] {
        var dict: [String: String] = [:]
        for item in response.dataList {
            dict[item.name] = item.value
        }
        return dict
    }

    private static func required(_ key: String, in dict: [String: String]) throws -> String {
        guard let value = dict[key] else { throw ParseError.missingValue(key) }
        return value
    }

    private static func int(_ key: String, in dict: [String: String]) throws -> Int {
        let raw = try required(key, in: dict)
        guard let value = Int(raw) else { throw ParseError.invalidInt(key, raw) }
        return value
    }

    private static func double(_ key: String, in dict: [String: String]) throws -> Double {
        let raw = try required(key, in: dict)
        guard let value = Double(raw) else { throw ParseError.invalidDouble(key, raw) }
        return value
    }

    private static func bool(_ key: String, in dict: [String: String]) throws -> Bool {
        let raw = try required(key, in: dict)
        switch raw.lowercased() {
        case "true", "1", "on", "yes":
            return true
        case "false", "0", "off", "no":
            return false
        default:
            throw ParseError.invalidBool(key, raw)
        }
    }

    private static func time(startHourKey: String, startMinuteKey: String, endHourKey: String, endMinuteKey: String, in dict: [String: String]) throws -> (start: Time, end: Time) {
        let sh = try int(startHourKey, in: dict)
        let sm = try int(startMinuteKey, in: dict)
        let eh = try int(endHourKey, in: dict)
        let em = try int(endMinuteKey, in: dict)
        return (Time(hour: sh, minute: sm), Time(hour: eh, minute: em))
    }

    private static func optionalTime(startHourKey: String, startMinuteKey: String, endHourKey: String, endMinuteKey: String, in dict: [String: String]) -> (start: Time, end: Time)? {
        guard let shRaw = dict[startHourKey],
              let smRaw = dict[startMinuteKey],
              let ehRaw = dict[endHourKey],
              let emRaw = dict[endMinuteKey],
              let sh = Int(shRaw),
              let sm = Int(smRaw),
              let eh = Int(ehRaw),
              let em = Int(emRaw) else {
            return nil
        }
        return (Time(hour: sh, minute: sm), Time(hour: eh, minute: em))
    }

    static func from(response: BatteryHeatingScheduleResponse) throws -> Self {
        let dict = try dictionary(from: response)

        let enabled = try bool("batteryWarmUpEnable", in: dict)
        let minStartTemperature = try double("minStartTemperatureRange", in: dict)
        let maxStartTemperature = try double("maxStartTemperatureRange", in: dict)
        let minEndTemperature = try double("minEndTemperatureRange", in: dict)
        let maxEndTemperature = try double("maxEndTemperatureRange", in: dict)
        let period1Enabled = try bool("time1Enable", in: dict)
        let period2Enabled = try bool("time2Enable", in: dict)
        let period3Enabled = try bool("time3Enable", in: dict)
        let warmUpState = dict["batteryWarmUpState"]

        let period1 = try time(
            startHourKey: "time1StartHour",
            startMinuteKey: "time1StartMinute",
            endHourKey: "time1EndHour",
            endMinuteKey: "time1EndMinute",
            in: dict
        )

        let period2 = optionalTime(
            startHourKey: "time2StartHour",
            startMinuteKey: "time2StartMinute",
            endHourKey: "time2EndHour",
            endMinuteKey: "time2EndMinute",
            in: dict
        ) ?? (Time(hour: 0, minute: 0), Time(hour: 0, minute: 0))

        let period3 = optionalTime(
            startHourKey: "time3StartHour",
            startMinuteKey: "time3StartMinute",
            endHourKey: "time3EndHour",
            endMinuteKey: "time3EndMinute",
            in: dict
        ) ?? (Time(hour: 0, minute: 0), Time(hour: 0, minute: 0))

        return BatteryHeatingSchedule(
            enabled: enabled,
            warmUpState: warmUpState,
            period1Start: period1.start,
            period1End: period1.end,
            period1Enabled: period1Enabled,
            period2Start: period2.start,
            period2End: period2.end,
            period2Enabled: period2Enabled,
            period3Start: period3.start,
            period3End: period3.end,
            period3Enabled: period3Enabled,
            minStartTemperature: minStartTemperature,
            maxStartTemperature: maxStartTemperature,
            minEndTemperature: minEndTemperature,
            maxEndTemperature: maxEndTemperature
        )
    }
}
