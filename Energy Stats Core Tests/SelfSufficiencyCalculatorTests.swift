//
//  SelfSufficiencyCalculatorTests.swift
//  Energy Stats Core Tests
//
//  Created by Alistair Priest on 26/06/2023.
//

import Energy_Stats_Coreimport XCTest

final class AbsoluteSelfSufficiencyCalculatorTests: XCTestCase {
    func test_Calculates_When_Some_Grid_Usage() {
        let (result, breakdown) = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: 300)

        XCTAssertEqual(result, 0.97)
        XCTAssertEqual(breakdown.formula, "1 - (min(loads, max(grid, 0.00)) / loads)")
        XCTAssertEqual(breakdown.calculation(1), "1 - (min(10000.0, max(300.0, 0.0) / 10000.0")
    }

    func test_Calculates_When_No_Grid_Usage() {
        let (result, breakdown) = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: 0)

        XCTAssertEqual(result, 1)
        XCTAssertEqual(breakdown.calculation(1), "1 - (min(10000.0, max(0.0, 0.0) / 10000.0")
    }

    func test_Calculates_When_Completely_Grid_Usage() {
        let (result, breakdown) = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: 10000)

        XCTAssertEqual(result, 0)
        XCTAssertEqual(breakdown.calculation(1), "1 - (min(10000.0, max(10000.0, 0.0) / 10000.0")
    }

    func test_Calculates_When_Grid_Usage_Over_Load() {
        let (result, breakdown) = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: 11000)

        XCTAssertEqual(result, 0)
        XCTAssertEqual(breakdown.calculation(1), "1 - (min(10000.0, max(11000.0, 0.0) / 10000.0")
    }

    func test_Calculates_When_Grid_Negative() {
        let (result, breakdown) = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: -50)

        XCTAssertEqual(result, 1)
        XCTAssertEqual(breakdown.calculation(1), "1 - (min(10000.0, max(-50.0, 0.0) / 10000.0")
    }

    func test_Calculates_When_No_Loads() {
        let (result, breakdown) = AbsoluteSelfSufficiencyCalculator.calculate(loads: 0, grid: -50)

        XCTAssertEqual(result, 0)
        XCTAssertEqual(breakdown.calculation(1), "")
    }
}

final class NetSelfSufficiencyCalculatorTests: XCTestCase {
    func test_Calculates_With_FeedIn() {
        let (result, breakdown) = NetSelfSufficiencyCalculator.calculate(grid: 300, feedIn: 10000, loads: 10000, batteryCharge: 1000, batteryDischarge: 500)

        XCTAssertEqual(result, 1)
        XCTAssertEqual(breakdown.formula, """
        netGeneration = feedIn - grid + batteryCharge - batteryDischarge

        If netGeneration > 0 then result = 1
        Else if netGeneration + homeConsumption < 0 then result = 0
        Else if netGeneration + homeConsumption > 0 then result = (netGeneration + homeConsumption) / homeConsumption
        """)
        XCTAssertEqual(breakdown.calculation(1), """
        netGeneration = 10000.0 - 300.0 + 1000.0 - 500.0

        If 10200.0 > 0 then result = 1
        Else if 10200.0 + 10000.0 < 0 then result = 0
        Else if 10200.0 + 10000.0 > 0 then result = (10200.0 + 10000.0) / 10000.0
        """)
    }

    func test_Calculates_When_NoFeedIn() {
        let (result, breakdown) = NetSelfSufficiencyCalculator.calculate(grid: 300, feedIn: 0, loads: 10000, batteryCharge: 0, batteryDischarge: 0)

        XCTAssertEqual(result, 0.97)
        XCTAssertEqual(breakdown.calculation(1), """
        netGeneration = 0.0 - 300.0 + 0.0 - 0.0

        If -300.0 > 0 then result = 1
        Else if -300.0 + 10000.0 < 0 then result = 0
        Else if -300.0 + 10000.0 > 0 then result = (-300.0 + 10000.0) / 10000.0
        """)
    }

    func test_Calculates_When_Consumed_Half_From_Grid() {
        let (result, breakdown) = NetSelfSufficiencyCalculator.calculate(grid: 4000, feedIn: 0, loads: 8000, batteryCharge: 0, batteryDischarge: 0)

        XCTAssertEqual(result, 0.5)
        XCTAssertEqual(breakdown.calculation(1), """
        netGeneration = 0.0 - 4000.0 + 0.0 - 0.0

        If -4000.0 > 0 then result = 1
        Else if -4000.0 + 8000.0 < 0 then result = 0
        Else if -4000.0 + 8000.0 > 0 then result = (-4000.0 + 8000.0) / 8000.0
        """)
    }

    func test_Calculates_When_Consumed_All_From_Grid() {
        let (result, breakdown) = NetSelfSufficiencyCalculator.calculate(grid: 8000, feedIn: 0, loads: 8000, batteryCharge: 0, batteryDischarge: 0)

        XCTAssertEqual(result, 0.0)
        XCTAssertEqual(breakdown.calculation(1), """
        netGeneration = 0.0 - 8000.0 + 0.0 - 0.0

        If -8000.0 > 0 then result = 1
        Else if -8000.0 + 8000.0 < 0 then result = 0
        Else if -8000.0 + 8000.0 > 0 then result = (-8000.0 + 8000.0) / 8000.0
        """)
    }

    func test_Calculates_When_Grid_Higher_Than_Loads() {
        let (result, breakdown) = NetSelfSufficiencyCalculator.calculate(grid: 9000, feedIn: 0, loads: 8000, batteryCharge: 0, batteryDischarge: 0)

        XCTAssertEqual(result, 0.0)
        XCTAssertEqual(breakdown.calculation(1), """
        netGeneration = 0.0 - 9000.0 + 0.0 - 0.0

        If -9000.0 > 0 then result = 1
        Else if -9000.0 + 8000.0 < 0 then result = 0
        Else if -9000.0 + 8000.0 > 0 then result = (-9000.0 + 8000.0) / 8000.0
        """)
    }
}
