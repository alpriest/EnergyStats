//
//  Double+Capped.swift
//  Energy Stats Core Tests
//
//  Created by Alistair Priest on 26/10/2023.
//

import Foundation
import XCTest
@testable import Energy_Stats_Core

class DoubleTests: XCTestCase {
    func test_full_large_number() {
        XCTAssertTrue(201539769.0.capped().sameValueAs(other: 3461.8))
    }

    func test_3dp_decimal_numbers() {
        XCTAssertTrue(1.234.capped().sameValueAs(other: 1.234))
    }

    func test_2dp_full_decimal_numbers() {
        XCTAssertTrue(1.200.capped().sameValueAs(other: 1.200))
    }
}
