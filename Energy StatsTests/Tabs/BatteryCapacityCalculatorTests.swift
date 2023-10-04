//
//  BatteryCapacityCalculatorTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 04/04/2023.
//

@testable import Energy_Stats
import Energy_Stats_Core
import XCTest

final class BatteryCapacityCalculatorTests: XCTestCase {
    func test_returnsBatteryPercentageRemaining_IncludingUnusableMinSOC() {
        let sut = BatteryCapacityCalculator(capacityW: 10000, minimumSOC: 0.2)

        let result = sut.batteryChargeStatusDescription(
            batteryChargePowerkWH: 1.0,
            batteryStateOfCharge: 0.5
        )

        let charge = sut.currentEstimatedChargeAmountWh(batteryStateOfCharge: 0.5, includeUnusableCapacity: true)

        XCTAssertEqual(charge, 5000)
        XCTAssertEqual(result, "Full in 5 hours")
    }

    func test_returnsBatteryPercentageRemaining_ExcludingUnusableMinSOC() {
        let sut = BatteryCapacityCalculator(capacityW: 10000, minimumSOC: 0.2)

        let result = sut.batteryChargeStatusDescription(
            batteryChargePowerkWH: 1.0,
            batteryStateOfCharge: 0.5
        )

        let charge = sut.currentEstimatedChargeAmountWh(batteryStateOfCharge: 0.5, includeUnusableCapacity: false)

        XCTAssertEqual(charge, 3000)
        XCTAssertEqual(result, "Full in 5 hours")
    }

    func test_CalculatesRemainingTimeUntilFull() {
        let sut = BatteryCapacityCalculator(capacityW: 8000, minimumSOC: 0.2)
        let result = sut.batteryChargeStatusDescription(batteryChargePowerkWH: 1.0, batteryStateOfCharge: 0.50)

        XCTAssertEqual(result, "Full in 4 hours")
    }

    func test_CalculatesRemainingTimeUntilEmpty() {
        let sut = BatteryCapacityCalculator(capacityW: 8000, minimumSOC: 0.2)
        let result = sut.batteryChargeStatusDescription(batteryChargePowerkWH: -1.0, batteryStateOfCharge: 0.50)

        XCTAssertEqual(result, "Empty in 2 hours")
    }
}
