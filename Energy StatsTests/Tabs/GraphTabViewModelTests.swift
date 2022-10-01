//
//  GraphTabViewModelTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 01/10/2022.
//

@testable import Energy_Stats
import XCTest

@MainActor
final class GraphTabViewModelTests: XCTestCase {
    var sut: GraphTabViewModel!
    var networking: Networking!
    var config: MockConfig!

    override func setUp() {
        config = MockConfig()
        config.deviceID = "device1"
        networking = Network(credentials: MockKeychainStore(), config: config)
        sut = GraphTabViewModel(networking, { Date(timeIntervalSince1970: 1664107252) })
    }

    func test_initial_values() {
        XCTAssertEqual(sut.data.count, 0)
        XCTAssertEqual(sut.hours, 6)
        XCTAssertEqual(sut.stride, 1)
        XCTAssertEqual(sut.variables, [GraphVariable(.feedinPower), GraphVariable(.gridConsumptionPower), GraphVariable(.generationPower), GraphVariable(.batChargePower), GraphVariable(.pvPower)])
        XCTAssertNil(sut.errorMessage)
    }

    func test_fetches_data_on_start() async {
        stubHTTPResponses(with: [.reportSuccess, .rawSuccess])

        await sut.start()

        XCTAssertEqual(sut.data.count, 564)
    }

    func test_filters_when_hour_selected() async {
        stubHTTPResponses(with: [.reportSuccess, .rawSuccess])
        await sut.start()

        sut.hours = 12

        XCTAssertEqual(sut.data.count, 848)
    }
}
