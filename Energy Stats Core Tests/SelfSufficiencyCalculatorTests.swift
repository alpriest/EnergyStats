//
//  SelfSufficiencyCalculatorTests.swift
//  Energy Stats Core Tests
//
//  Created by Alistair Priest on 26/06/2023.
//

import Energy_Stats_Core
import XCTest

final class AbsoluteSelfSufficiencyCalculatorTests: XCTestCase {
    func test_Calculates_When_Some_Grid_Usage() {
        let result = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: 500)

        XCTAssertEqual(result, 0.95)
    }

    func test_Calculates_When_No_Grid_Usage() {
        let result = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: 0)

        XCTAssertEqual(result, 1)
    }

    func test_Calculates_When_Completely_Grid_Usage() {
        let result = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: 10000)

        XCTAssertEqual(result, 0)
    }

    func test_Calculates_When_Grid_Usage_Over_Load() {
        let result = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: 11000)

        XCTAssertEqual(result, 0)
    }

    func test_Calculates_When_Grid_Negative() {
        let result = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: -50)

        XCTAssertEqual(result, 1)
    }
}
