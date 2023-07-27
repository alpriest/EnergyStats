//
//  BatteryResponse.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

public struct BatteryResponse: Decodable {
    public let power: Double
    public let soc: Int
    public let residual: Double
    public let temperature: Double
}

public struct BatterySettingsResponse: Decodable {
    public let minGridSoc: Int
    public let minSoc: Int
}

public struct SetSOCRequest: Encodable {
    public let minGridSoc: Int
    public let minSoc: Int
    public let sn: String
}
