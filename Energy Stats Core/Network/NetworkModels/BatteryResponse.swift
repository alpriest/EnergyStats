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

    enum CodingKeys: CodingKey {
        case power
        case soc
        case residual
        case temperature
    }

    public init(power: Double, soc: Int, residual: Double, temperature: Double) {
        self.power = power
        self.soc = soc
        self.residual = residual
        self.temperature = temperature
    }
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
