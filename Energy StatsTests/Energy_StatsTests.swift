//
//  BatteryCalculatorTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 10/09/2022.
//

import XCTest
@testable import Energy_Stats

final class BatteryCalculatorTests: XCTestCase {

    func test_CalculatesRemainingTimeUntilFull() {
        let sut = BatteryCalculator(capacitykW: 8.0)
        let result = sut.batteryRemaining(batteryChargePowerkWH: 1.0, batteryStartOfCharge: 0.50)

        XCTAssertEqual(result, "Full in 4 hours")
    }

    func test_CalculatesRemainingTimeUntilEmpty() {
        let sut = BatteryCalculator(capacitykW: 8.0)
        let result = sut.batteryRemaining(batteryChargePowerkWH: -1.0, batteryStartOfCharge: 0.50)

        XCTAssertEqual(result, "Empty in 2 hours")
    }

}
