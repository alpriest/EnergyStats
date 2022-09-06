//
//  BatteryResponse.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

struct BatteryResponse: Decodable {
    let errno: Int
    let result: BatteryResult

    struct BatteryResult: Decodable {
        let soc: Int
    }
}
