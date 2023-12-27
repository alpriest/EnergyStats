//
//  FoxEssCloudParseStrategyTests.swift
//  Energy Stats Core Tests
//
//  Created by Alistair Priest on 26/10/2023.
//

import XCTest
@testable import Energy_Stats_Core
final class FoxEssCloudParseStrategyTests: XCTestCase {
    func test_ParsesDatesWithDoubleTimezoneEncoded() throws {
        let date = "2023-10-26 03:10:49 +03+0300"
        let result = try FoxEssCloudParseStrategy().parse(date)

        XCTAssertEqual(result.iso8601(), "2023-10-26T00:10:49Z")
    }

    func test_ParsesDateWithGMTtimezone() throws {
        let date = "2023-03-14 06:47:12 GMT+0000"
        let result = try FoxEssCloudParseStrategy().parse(date)

        XCTAssertEqual(result.iso8601(), "2023-03-14T06:47:12Z")
    }
}
