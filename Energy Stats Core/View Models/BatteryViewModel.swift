//
//  BatteryViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

public struct BatteryViewModel: Sendable {
    public let hasBattery: Bool
    public let chargeLevel: Double
    public let chargePower: Double
    public let temperature: Double

    public init(from battery: BatteryResponse) {
        chargeLevel = Double(battery.soc) / 100.0

        let powerAsCharge = 0 - battery.power
        chargePower = powerAsCharge
        hasBattery = true
        temperature = battery.temperature
    }

    public init() {
        hasBattery = false
        chargeLevel = 0
        chargePower = 0
        temperature = 0
    }
}

public extension BatteryViewModel {
    static var noBattery: BatteryViewModel {
        BatteryViewModel()
    }
}
