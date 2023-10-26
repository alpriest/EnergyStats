//
//  SelfSufficiencyCalculatorTests.swift
//  Energy Stats Core Tests
//
//  Created by Alistair Priest on 26/06/2023.
//

import Energy_Stats_Core
import XCTest

//final class AbsoluteSelfSufficiencyCalculatorTests: XCTestCase {
//    func test_Calculates_When_Some_Grid_Usage() {
//        let result = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: 300)
//
//        XCTAssertEqual(result, 0.97)
//    }
//
//    func test_Calculates_When_No_Grid_Usage() {
//        let result = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: 0)
//
//        XCTAssertEqual(result, 1)
//    }
//
//    func test_Calculates_When_Completely_Grid_Usage() {
//        let result = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: 10000)
//
//        XCTAssertEqual(result, 0)
//    }
//
//    func test_Calculates_When_Grid_Usage_Over_Load() {
//        let result = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: 11000)
//
//        XCTAssertEqual(result, 0)
//    }
//
//    func test_Calculates_When_Grid_Negative() {
//        let result = AbsoluteSelfSufficiencyCalculator.calculate(loads: 10000, grid: -50)
//
//        XCTAssertEqual(result, 1)
//    }
//
//    func test_Calculates_When_No_Loads() {
//        let result = AbsoluteSelfSufficiencyCalculator.calculate(loads: 0, grid: -50)
//
//        XCTAssertEqual(result, 0)
//    }
//}
//
//final class NetSelfSufficiencyCalculatorTests: XCTestCase {
//    func test_Calculates_With_FeedIn() {
//        let result = NetSelfSufficiencyCalculator.calculate(grid: 300, feedIn: 10000, loads: 10000, batteryCharge: 1000, batteryDischarge: 500)
//
//        XCTAssertEqual(result, 1)
//    }
//
//    func test_Calculates_When_NoFeedIn() {
//        let result = NetSelfSufficiencyCalculator.calculate(grid: 300, feedIn: 0, loads: 10000, batteryCharge: 0, batteryDischarge: 0)
//
//        XCTAssertEqual(result, 0.97)
//    }
//
//    func test_Calculates_When_Consumed_Half_From_Grid() {
//        let result = NetSelfSufficiencyCalculator.calculate(grid: 4000, feedIn: 0, loads: 8000, batteryCharge: 0, batteryDischarge: 0)
//
//        XCTAssertEqual(result, 0.5)
//    }
//
//    func test_Calculates_When_Consumed_All_From_Grid() {
//        let result = NetSelfSufficiencyCalculator.calculate(grid: 8000, feedIn: 0, loads: 8000, batteryCharge: 0, batteryDischarge: 0)
//
//        XCTAssertEqual(result, 0.0)
//    }
//
//    func test_Calculates_When_Grid_Higher_Than_Loads() {
//        let result = NetSelfSufficiencyCalculator.calculate(grid: 9000, feedIn: 0, loads: 8000, batteryCharge: 0, batteryDischarge: 0)
//
//        XCTAssertEqual(result, 0.0)
//    }
//}
