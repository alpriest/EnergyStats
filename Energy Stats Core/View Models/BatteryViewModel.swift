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
    public let residual: Int
    public let error: Error?

    public init(from battery: BatteryResponse) {
        chargeLevel = Double(battery.soc) / 100.0

        let powerAsCharge = 0 - battery.power
        chargePower = powerAsCharge
        hasBattery = true
        temperature = battery.temperature
        residual = Int(battery.residual)
        error = nil
    }

    public init(hasBattery: Bool = false,
                chargeLevel: Double = 0,
                chargePower: Double = 0,
                temperature: Double = 0,
                residual: Int = 0) {
        self.hasBattery = hasBattery
        self.chargeLevel = chargeLevel
        self.chargePower = chargePower
        self.temperature = temperature
        self.residual = residual
        error = nil
    }

    public init(error: Error) {
        self.error = error
        hasBattery = false
        chargeLevel = 0
        chargePower = 0
        temperature = 0
        residual = 0
    }
}

public extension BatteryViewModel {
    static var noBattery: BatteryViewModel {
        BatteryViewModel()
    }
}
