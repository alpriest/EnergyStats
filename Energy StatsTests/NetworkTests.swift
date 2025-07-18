//
//  NetworkTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 25/09/2022.
//

@testable import Energy_Stats
@testable import Energy_Stats_Core
import OHHTTPStubs
import XCTest

final class NetworkTests: XCTestCase {
    private var sut: FoxAPIServicing!
    private var keychainStore: MockKeychainStore!

    override func setUp() {
        keychainStore = MockKeychainStore()
        sut = FoxAPIService(credentials: keychainStore, urlSession: URLSession.shared)
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
    }

    func test_fetchReport_returns_data_on_success() async throws {
        stubHTTPResponse(with: .reportSuccess)

        let report = try await sut.openapi_fetchReport(
            deviceSN: "any",
            variables: [
                .feedIn,
                .gridConsumption,
                .generation,
                .chargeEnergyToTal,
                .dischargeEnergyToTal
            ],
            queryDate: QueryDate.any(),
            reportType: .day
        )

        XCTAssertEqual(report.count, 5)
    }

    func test_fetchReal_returns_data_on_success() async throws {
        stubHTTPResponse(with: .realSuccess)

        let raw = try await sut.openapi_fetchRealData(deviceSN: "DEVICESN", variables: [
            Variable(name: "feedinPower", variable: "feedinPower", unit: "kWH"),
            Variable(name: "gridConsumptionPower", variable: "gridConsumptionPower", unit: "kWH"),
            Variable(name: "batChargePower", variable: "batChargePower", unit: "kWH"),
            Variable(name: "batDischargePower", variable: "batDischargePower", unit: "kWH"),
            Variable(name: "generationPower", variable: "generationPower", unit: "kWH"),
            Variable(name: "ResidualEnergy", variable: "ResidualEnergy", unit: "kWH"),
            Variable(name: "batTemperature", variable: "batTemperature", unit: "℃"),
        ].map { $0.variable })

        XCTAssertEqual(raw.datas.count, 7)
    }

    func test_fetchDeviceList_returns_data_on_success() async throws {
        stubHTTPResponse(with: .deviceListSuccess)

        let devices = try await sut.openapi_fetchDeviceList()

        XCTAssertEqual(devices.first?.deviceSN, "DEVICESN")
    }

    func test_fetchReport_throws_when_offline() async {
        stubOffline()

        do {
            _ = try await sut.openapi_fetchReport(deviceSN: "!", variables: [.feedIn, .gridConsumption, .generation, .chargeEnergyToTal], queryDate: QueryDate.any(), reportType: .day)
        } catch NetworkError.offline {
        } catch {
            XCTFail()
        }
    }

    func test_fetchReport_returns_tryLater() async {
        stubHTTPResponse(with: .tryLaterFailure)

        do {
            _ = try await sut.openapi_fetchReport(deviceSN: "1", variables: [.feedIn, .gridConsumption, .generation, .chargeEnergyToTal], queryDate: QueryDate.any(), reportType: .day)
        } catch NetworkError.tryLater {
        } catch {
            XCTFail()
        }
    }
}

extension QueryDate {
    static func any() -> QueryDate {
        .init(year: 2022, month: 11, day: 22)
    }
}
