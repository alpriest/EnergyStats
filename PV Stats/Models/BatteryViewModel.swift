//
//  BatteryViewModel.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

struct BatteryViewModel: Sendable {
    let chargeLevel: Double

    init(from batteryResponse: BatteryResponse) {
        chargeLevel = Double(batteryResponse.result.soc) / 100.0
    }
}
