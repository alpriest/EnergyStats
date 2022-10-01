//
//  GraphTabViewModelTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 01/10/2022.
//

import XCTest
@testable import Energy_Stats

final class GraphTabViewModelTests: XCTestCase {
    func test_initial_values() {
        let sut = GraphTabViewModel(MockNetworking())

        XCTAssertEqual(sut.data.count, 0)
        XCTAssertEqual(sut.hours, 6)
        XCTAssertEqual(sut.stride, 1)
        XCTAssertEqual(sut.variables, [GraphVariable(.feedinPower), GraphVariable(.gridConsumptionPower), GraphVariable(.generationPower), GraphVariable(.batChargePower), GraphVariable(.pvPower)])
        XCTAssertNil(sut.errorMessage)
    }
}
