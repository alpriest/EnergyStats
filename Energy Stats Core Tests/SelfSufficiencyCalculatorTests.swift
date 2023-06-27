//
//  SelfSufficiencyCalculatorTests.swift
//  Energy Stats Core Tests
//
//  Created by Alistair Priest on 26/06/2023.
//

import Energy_Stats_Core
import XCTest

final class SelfSufficiencyCalculatorTests: XCTestCase {
    func test_Calculates_When_No_FeedIn() {
        let sut = SelfSufficiencyCalculator()

        let result = sut.calculate(generation: 10000, feedIn: 0, grid: 0, batteryCharge: 0.0, batteryDischarge: 0.0)

        XCTAssertEqual(result, 1)
    }

    func test_Calculates_When_FeedIn() {
        let sut = SelfSufficiencyCalculator()

        let result = sut.calculate(generation: 10000, feedIn: 1000, grid: 0, batteryCharge: 0.0, batteryDischarge: 0.0)

        XCTAssertEqual(result, 1)
    }

    func test_Calculates_When_Battery_Charge_And_Discharge_Equal() {
        let sut = SelfSufficiencyCalculator()

        let result = sut.calculate(generation: 10000, feedIn: 1000, grid: 0, batteryCharge: 2000, batteryDischarge: 2000)

        XCTAssertEqual(result, 1)
    }

    func test_Calculates_When_Drawing_From_Grid() {
        let sut = SelfSufficiencyCalculator()

        let result = sut.calculate(generation: 19000, feedIn: 10000, grid: 1000, batteryCharge: 0, batteryDischarge: 0)

        XCTAssertEqual(result, 0.9)
    }

    func test_Calculates_When_Drawing_From_Grid_And_Exporting() {
        let sut = SelfSufficiencyCalculator()

        let result = sut.calculate(generation: 3000, feedIn: 300, grid: 300, batteryCharge: 0, batteryDischarge: 0)

        XCTAssertEqual(result, 0.9)
    }

    func test_Calculates_When_Using_Battery_Too() {
        let sut = SelfSufficiencyCalculator()

        let result = sut.calculate(generation: 10000, feedIn: 300, grid: 300, batteryCharge: 2000, batteryDischarge: 3000)

        XCTAssertEqual(result, 0.973)
    }
}
