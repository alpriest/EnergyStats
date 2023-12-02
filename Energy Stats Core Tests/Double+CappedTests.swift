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
    func test_large_number_without_capping_does_not_cap() {
        assertSameValueAs(first: 201539769.capped(.none), second: 201539769)
    }

    func test_large_number_with_mild_capping_does_cap() {
        assertSameValueAs(first: 201539769.capped(.mild), second: 3461.8)
    }

    func test_small_number_with_mild_capping_does_not_cap() {
        assertSameValueAs(first: 45899.7.capped(.mild), second: 45899.7)
    }

    func test_small_number_with_enhanced_capping_does_cap() {
        assertSameValueAs(first: 45899.7.capped(.enhanced), second: 24.5)
    }

    func test_3dp_decimal_numbers() {
        assertSameValueAs(first: 1.234.capped(.mild), second: 1.234)
    }

    func test_2dp_full_decimal_numbers() {
        assertSameValueAs(first: 1.200.capped(.mild), second: 1.200)
    }

    private func assertSameValueAs(first: Double, second: Double, file: StaticString = #file, line: UInt = #line) {
        if abs(first - second) > 0.0000001 {
            XCTFail("Expected \(first) to equal \(second)", file: file, line: line)
        }
    }
}
