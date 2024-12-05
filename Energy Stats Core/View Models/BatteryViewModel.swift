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
    public let temperatures: BatteryTemperatures
    public let residual: Int
    public let error: Error?

    public init(power: Double, soc: Int, residual: Double, temperatures: BatteryTemperatures) {
        chargeLevel = Double(soc) / 100.0
        chargePower = power
        hasBattery = true
        self.temperatures = temperatures
        self.residual = Int(residual)
        error = nil
    }

    public init(
        hasBattery: Bool = false,
        chargeLevel: Double = 0,
        chargePower: Double = 0,
        temperatures: BatteryTemperatures = BatteryTemperatures(
            batTemperature: nil,
            batTemperature_1: nil,
            batTemperature_2: nil
        ),
        residual: Int = 0
    )
    {
        self.hasBattery = hasBattery
        self.chargeLevel = chargeLevel
        self.chargePower = chargePower
        self.temperatures = temperatures
        self.residual = residual
        error = nil
    }

    public init(error: Error) {
        self.error = error
        hasBattery = false
        chargeLevel = 0
        chargePower = 0
        temperatures = BatteryTemperatures(batTemperature: nil, batTemperature_1: nil, batTemperature_2: nil)
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
            temperatures: BatteryTemperatures(batTemperature: TemperatureData(value: 15.6, name: "BMS"), batTemperature_1: nil, batTemperature_2: nil),
            residual: 5678
        )
    }

    static func make(currentDevice: Device, real: OpenQueryResponse) -> BatteryViewModel {
        if currentDevice.hasBattery == true {
            return real.makeBatteryViewModel()
        } else {
            return BatteryViewModel.noBattery
        }
    }
}

extension OpenQueryResponse {
    func makeBatteryViewModel() -> BatteryViewModel {
        let chargePower = datas.currentDouble(for: "batChargePower")
        let dischargePower = datas.currentDouble(for: "batDischargePower")
        let power = chargePower > 0 ? chargePower : -dischargePower
        let temps = BatteryTemperatures(
            batTemperature: TemperatureData(value: datas.current(for: "batTemperature")?.value, name: "BMS"),
            batTemperature_1: TemperatureData(value: datas.current(for: "batTemperature_1")?.value, name: "BMS1"),
            batTemperature_2: TemperatureData(value: datas.current(for: "batTemperature_2")?.value, name: "BMS2")
        )

        return BatteryViewModel(
            power: power,
            soc: Int(datas.SoC()),
            residual: datas.currentDouble(for: "ResidualEnergy") * 10.0,
            temperatures: temps
        )
    }
}

public struct BatteryTemperatures: Sendable {
    public let batTemperature: TemperatureData?
    public let batTemperature_1: TemperatureData?
    public let batTemperature_2: TemperatureData?

    public init(batTemperature: TemperatureData?, batTemperature_1: TemperatureData?, batTemperature_2: TemperatureData?) {
        self.batTemperature = batTemperature
        self.batTemperature_1 = batTemperature_1
        self.batTemperature_2 = batTemperature_2
    }
}

public struct TemperatureData: Sendable, Identifiable {
    public let value: Double
    public let name: String

    public var id: String { name }

    public init?(value: Double?, name: String) {
        guard let value else { return nil }

        self.value = value
        self.name = name
    }
}
