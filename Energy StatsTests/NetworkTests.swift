//
//  NetworkTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 25/09/2022.
//

@testable import Energy_Stats
@testable import Energy_Stats_Core
import XCTest

final class NetworkTests: XCTestCase {
    private var sut: FoxESSNetworking!
    private var keychainStore: MockKeychainStore!

    override func setUp() {
        keychainStore = MockKeychainStore()
        sut = Network(credentials: keychainStore, store: InMemoryLoggingNetworkStore())
    }

    func test_verifyCredentials_does_not_throw_on_success() async throws {
        stubHTTPResponse(with: .loginSuccess)

        try await sut.verifyCredentials(username: "bob", hashedPassword: "secret")
    }

    func test_verifyCredentials_throws_on_failure() async throws {
        stubHTTPResponse(with: .loginFailure)

        do {
            try await sut.verifyCredentials(username: "bob", hashedPassword: "secret")
        } catch NetworkError.badCredentials {
        } catch {
            XCTFail()
        }
    }

    func test_ensureTokenValid_fetches_new_token_if_none() async throws {
        keychainStore.token = nil
        keychainStore.username = "bob"
        keychainStore.hashedPassword = "secrethash"
        stubHTTPResponse(with: .loginSuccess)

        await sut.ensureHasToken()

        XCTAssertNotNil(keychainStore.token)
    }

    func test_ensureTokenValid_fetches_device_list_if_token_present() async throws {
        keychainStore.token = "token"
        stubHTTPResponse(with: .deviceListSuccess)

        await sut.ensureHasToken()

        XCTAssertNotNil(keychainStore.token)
    }

    func test_fetchReport_returns_data_on_success() async throws {
        stubHTTPResponse(with: .reportSuccess)

        let report = try await sut.fetchReport(deviceID: "any", variables: [.feedIn, .gridConsumption, .generation, .chargeEnergyToTal, .dischargeEnergyToTal], queryDate: QueryDate.any(), reportType: .day)

        XCTAssertEqual(report.count, 5)
    }

    func test_fetchBattery_returns_data_on_success() async throws {
        stubHTTPResponse(with: .batterySuccess)

        let report = try await sut.fetchBattery(deviceID: "any")

        XCTAssertEqual(report.power, -1.065)
        XCTAssertEqual(report.soc, 23)
    }

    func test_fetchRaw_returns_data_on_success() async throws {
        stubHTTPResponse(with: .rawSuccess)

        let raw = try await sut.fetchRaw(deviceID: "1", variables: [
            RawVariable(name: "feedinPower", variable: "feedinPower", unit: "kWH"),
            RawVariable(name: "gridConsumptionPower", variable: "gridConsumptionPower", unit: "kWH"),
            RawVariable(name: "batChargePower", variable: "batChargePower", unit: "kWH"),
            RawVariable(name: "batDischargePower", variable: "batDischargePower", unit: "kWH"),
            RawVariable(name: "generationPower", variable: "generationPower", unit: "kWH")], queryDate: .any())

        XCTAssertEqual(raw.count, 5)
    }

    func test_fetchDeviceList_returns_data_on_success() async throws {
        stubHTTPResponse(with: .deviceListSuccess)

        let devices = try await sut.fetchDeviceList()

        XCTAssertEqual(devices.first?.hasBattery, false)
        XCTAssertEqual(devices.first?.deviceID, "12345678-0000-0000-1234-aaaabbbbcccc")
    }

    func test_fetchReport_throws_when_offline() async {
        stubOffline()

        do {
            _ = try await sut.fetchReport(deviceID: "!", variables: [.feedIn, .gridConsumption, .generation, .chargeEnergyToTal], queryDate: QueryDate.any(), reportType: .day)
        } catch NetworkError.offline {
        } catch {
            XCTFail()
        }
    }

    func test_fetchReport_returns_tryLater() async {
        stubHTTPResponse(with: .tryLaterFailure)

        do {
            _ = try await sut.fetchReport(deviceID: "1", variables: [.feedIn, .gridConsumption, .generation, .chargeEnergyToTal], queryDate: QueryDate.any(), reportType: .day)
        } catch NetworkError.tryLater {
        } catch {
            XCTFail()
        }
    }

    func test_fetchReport_withInvalidToken_requestsToken_andRetriesOriginalFetch() async throws {
        keychainStore.username = "bob"
        keychainStore.hashedPassword = "secrethash"
        stubHTTPResponses(with: [.badTokenFailure, .loginSuccess, .reportSuccess])

        _ = try await sut.fetchReport(deviceID: "1", variables: [.feedIn, .gridConsumption, .generation, .chargeEnergyToTal], queryDate: QueryDate.any(), reportType: .day)
    }
}

extension QueryDate {
    static func any() -> QueryDate {
        .init(year: 2022, month: 11, day: 22)
    }
}
