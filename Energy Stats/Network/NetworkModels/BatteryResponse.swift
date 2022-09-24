//
//  BatteryResponse.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

struct BatteryResponse: Decodable {
    let soc: Int
    let power: Double
}
