//
//  BatteryResponse.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

struct BatteryResponse: Decodable {
    let power: Double
    let soc: Int
    let residual: Double
}

struct BatterySettingsResponse: Decodable {
    let minSoc: Int
}
