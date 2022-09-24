//
//  BatteryCalculatorTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 10/09/2022.
//

@testable import Energy_Stats
import XCTest

final class BatteryCalculatorTests: XCTestCase {
    func test_CalculatesRemainingTimeUntilFull() {
        let sut = BatteryCapacityCalculator(capacitykW: 8000, minimumSOC: 0.2)
        let result = sut.batteryRemaining(batteryChargePowerkWH: 1.0, batteryStateOfCharge: 0.50)

        XCTAssertEqual(result, "Full in 4 hours")
    }

    func test_CalculatesRemainingTimeUntilEmpty() {
        let sut = BatteryCapacityCalculator(capacitykW: 8000, minimumSOC: 0.2)
        let result = sut.batteryRemaining(batteryChargePowerkWH: -1.0, batteryStateOfCharge: 0.50)

        XCTAssertEqual(result, "Empty in 2 hours")
    }
}
