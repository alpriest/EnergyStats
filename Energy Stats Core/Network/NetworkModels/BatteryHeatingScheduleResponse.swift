//
//  BatteryHeatingScheduleResponse.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/01/2026.
//

public struct BatteryHeatingScheduleResponse: Decodable {
    public let dataList: [BatteryHeatingParameter]
}

public struct BatteryHeatingParameter: Decodable {
    public let name: String
    public let value: String
    public let unit: String?
}

public struct GetBatteryHeatingScheduleRequest: Encodable {
    public let sn: String
}

public struct BatteryHeatingScheduleRequest: Codable {
    public let sn: String
    public let batteryWarmUpEnable: String
    public let startTemperature: String
    public let endTemperature: String
    public let time1Enable: String
    public let time1StartHour: String
    public let time1StartMinute: String
    public let time1EndHour: String
    public let time1EndMinute: String
    public let time2Enable: String
    public let time2StartHour: String
    public let time2StartMinute: String
    public let time2EndHour: String
    public let time2EndMinute: String
    public let time3Enable: String
    public let time3StartHour: String
    public let time3StartMinute: String
    public let time3EndHour: String
    public let time3EndMinute: String
}
