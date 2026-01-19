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

public struct ParameterRange: Decodable {
    public let min: Double?
    public let max: Double?
}

public struct GetBatteryHeatingScheduleRequest: Encodable {
    public let sn: String
}
