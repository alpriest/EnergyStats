//
//  BatteryViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

struct BatteryViewModel: Sendable {
    let chargeLevel: Double
    let chargePowerTitle: String
    let chargePower: Double

    init(from batteryResponse: BatteryResponse) {
        chargeLevel = Double(batteryResponse.result.soc) / 100.0

        let powerAsCharge = 0 - batteryResponse.result.power
        chargePowerTitle = "\(powerAsCharge > 0 ? "Charging " : "Supplying ")\(powerAsCharge.kW())"
        chargePower = powerAsCharge
    }
}
