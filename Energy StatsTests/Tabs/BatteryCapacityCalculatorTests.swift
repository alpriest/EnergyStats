//
//  BatteryCapacityCalculatorTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 04/04/2023.
//

@testable import Energy_Stats
import Energy_Stats_Core
import Testing

struct BatteryCapacityCalculatorTests {
    @Test func `Returns battery percentage remaining including unusable minimum SOC`() {
        let sut = BatteryCapacityCalculator(capacityW: 10000, minimumSOC: 0.2)

        let result = sut.batteryChargeStatusDescription(
                        batteryChargePowerkW: 1.0,
            batteryStateOfCharge: 0.5
        )

        let charge = sut.currentEstimatedChargeAmountWh(batteryStateOfCharge: 0.5, includeUnusableCapacity: true)

        #expect(charge == 5000)
        #expect(result == "Full in 5 hours")
    }

    @Test func `Returns battery percentage remaining excluding unusable minimum SOC`() {
        let sut = BatteryCapacityCalculator(capacityW: 10000, minimumSOC: 0.2)

        let result = sut.batteryChargeStatusDescription(
                        batteryChargePowerkW: 1.0,
            batteryStateOfCharge: 0.5
        )

        let charge = sut.currentEstimatedChargeAmountWh(batteryStateOfCharge: 0.5, includeUnusableCapacity: false)

        #expect(charge == 3000)
        #expect(result == "Full in 5 hours")
    }

    @Test func `Calculates remaining time until full`() {
        let sut = BatteryCapacityCalculator(capacityW: 8000, minimumSOC: 0.2)
        let result = sut.batteryChargeStatusDescription(            batteryChargePowerkW: 1.0, batteryStateOfCharge: 0.50)

        #expect(result == "Full in 4 hours")
    }

    @Test func `Calculates remaining time until empty`() {
        let sut = BatteryCapacityCalculator(capacityW: 8000, minimumSOC: 0.2)
        let result = sut.batteryChargeStatusDescription(            batteryChargePowerkW: -1.0, batteryStateOfCharge: 0.50)

        #expect(result == "Empty in 2 hours")
    }
}
