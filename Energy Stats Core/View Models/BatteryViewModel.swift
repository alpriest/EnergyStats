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
    public let temperature: [Double]
    public let residual: Int
    public let error: Error?

    public init(power: Double, soc: Int, residual: Double, temperature: [Double]) {
        chargeLevel = Double(soc) / 100.0
        chargePower = power
        hasBattery = true
        self.temperature = temperature
        self.residual = Int(residual)
        error = nil
    }

    public init(hasBattery: Bool = false,
                chargeLevel: Double = 0,
                chargePower: Double = 0,
                temperature: [Double] = [0],
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
        temperature = [0]
        residual = 0
    }
}

public extension BatteryViewModel {
    static var noBattery: BatteryViewModel {
        BatteryViewModel()
    }

    static func any() -> BatteryViewModel {
        BatteryViewModel(
            hasBattery: true,
            chargeLevel: 0.99,
            chargePower: 0.1,
            temperature: [15.6],
            residual: 5678
        )
    }
}
