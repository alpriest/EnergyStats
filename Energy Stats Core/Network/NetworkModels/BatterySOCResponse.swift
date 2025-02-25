//
//  BatteryResponse.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

public struct BatterySOCResponse: Codable {
    public let minSocOnGrid: Int
    public let minSoc: Int

    public var minSocOnGridPercent: Double {
        Double(minSocOnGrid) / 100.0
    }
}

public struct SetBatterySOCRequest: Encodable {
    public let minSocOnGrid: Int
    public let minSoc: Int
    public let sn: String
}
