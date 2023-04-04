//
//  BatteryCapacityCalculatorTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 04/04/2023.
//

@testable import Energy_Stats
import XCTest

final class BatteryCapacityCalculatorTests: XCTestCase {
    func test_returnsBatteryPercentageRemaining_IncludingUnusableMinSOC() {
        let sut = BatteryCapacityCalculator(capacitykW: 10000, minimumSOC: 0.2, includeUnusableCapacity: true)

        let result = sut.batteryPercentageRemaining(
            batteryChargePowerkWH: 1.0,
            batteryStateOfCharge: 0.5
        )

        let charge = sut.currentEstimatedChargeAmountkW(batteryStateOfCharge: 0.5)

        XCTAssertEqual(charge, 5.0)
        XCTAssertEqual(result, "Full in 5 hours")
    }

    func test_returnsBatteryPercentageRemaining_ExcludingUnusableMinSOC() {
        let sut = BatteryCapacityCalculator(capacitykW: 10000, minimumSOC: 0.2, includeUnusableCapacity: false)

        let result = sut.batteryPercentageRemaining(
            batteryChargePowerkWH: 1.0,
            batteryStateOfCharge: 0.5
        )

        let charge = sut.currentEstimatedChargeAmountkW(batteryStateOfCharge: 0.5)

        XCTAssertEqual(charge, 3.0)
        XCTAssertEqual(result, "Full in 5 hours")
    }

    func test_CalculatesRemainingTimeUntilFull() {
        let sut = BatteryCapacityCalculator(capacitykW: 8000, minimumSOC: 0.2)
        let result = sut.batteryPercentageRemaining(batteryChargePowerkWH: 1.0, batteryStateOfCharge: 0.50)

        XCTAssertEqual(result, "Full in 4 hours")
    }

    func test_CalculatesRemainingTimeUntilEmpty() {
        let sut = BatteryCapacityCalculator(capacitykW: 8000, minimumSOC: 0.2)
        let result = sut.batteryPercentageRemaining(batteryChargePowerkWH: -1.0, batteryStateOfCharge: 0.50)

        XCTAssertEqual(result, "Empty in 2 hours")
    }
}
