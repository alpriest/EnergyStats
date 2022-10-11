//
//  BatteryViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

struct BatteryViewModel: Sendable {
    let hasBattery: Bool
    let chargeLevel: Double
    let chargePower: Double

    init(from battery: BatteryResponse) {
        chargeLevel = Double(battery.soc) / 100.0

        let powerAsCharge = 0 - battery.power
        chargePower = powerAsCharge
        hasBattery = true
    }

    init() {
        hasBattery = false
        chargeLevel = 0
        chargePower = 0
    }
}

extension BatteryViewModel {
    static var noBattery: BatteryViewModel {
        BatteryViewModel()
    }
}
