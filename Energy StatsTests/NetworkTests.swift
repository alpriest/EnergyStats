//
//  NetworkTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 25/09/2022.
//

@testable import Energy_Stats
import XCTest

final class NetworkTests: XCTestCase {
    private var sut: Networking!
    private var keychainStore: MockKeychainStore!
    private var config: MockConfig!

    override func setUp() {
        keychainStore = MockKeychainStore()
        config = MockConfig()
        sut = Network(credentials: keychainStore, config: config)
    }

    func test_verifyCredentials_does_not_throw_on_success() async throws {
        stubHTTPResponse(with: "login-success.json")

        try await sut.verifyCredentials(username: "bob", hashedPassword: "secret")
    }

    func test_verifyCredentials_throws_on_failure() async throws {
        stubHTTPResponse(with: "login-failure.json")

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
        stubHTTPResponse(with: "login-success.json")

        await sut.ensureTokenValid()

        XCTAssertNotNil(keychainStore.token)
    }

    func test_ensureTokenValid_fetches_device_list_if_token_present() async throws {
        keychainStore.token = "token"
        stubHTTPResponse(with: "devicelist-success.json")

        await sut.ensureTokenValid()

        XCTAssertNotNil(keychainStore.token)
    }

    func test_fetchReport_returns_data_on_success() async throws {
        config.configureAsLoggedIn()
        stubHTTPResponse(with: "report-success.json")

        let report = try await sut.fetchReport(variables: [.feedinPower, .gridConsumptionPower, .generationPower, .batChargePower, .pvPower])

        XCTAssertEqual(report.count, 5)
    }

    func test_fetchBattery_returns_data_on_success() async throws {
        config.configureAsLoggedIn()
        stubHTTPResponse(with: "battery-success.json")

        let report = try await sut.fetchBattery()

        XCTAssertEqual(report.power, -1.065)
        XCTAssertEqual(report.soc, 23)
    }

    func test_fetchRaw_returns_data_on_success() async throws {
        config.configureAsLoggedIn()
        stubHTTPResponse(with: "raw-success.json")

        let report = try await sut.fetchRaw(variables: [.feedinPower, .gridConsumptionPower, .pvPower, .loadsPower])

        XCTAssertEqual(report.count, 4)
    }

    func test_fetchDeviceList_returns_data_on_success() async throws {
        stubHTTPResponse(with: "devicelist-success.json")

        let report = try await sut.fetchDeviceList()

        XCTAssertEqual(report.devices.first?.hasBattery, true)
        XCTAssertEqual(report.devices.first?.deviceID, "03274209-486c-4ea3-9c28-159f25ee84cb")
    }

    func test_fetchReport_throws_when_offline() async {
        config.configureAsLoggedIn()
        stubOffline()
        
        do {
            _ = try await sut.fetchReport(variables: [.feedinPower, .gridConsumptionPower, .generationPower, .batChargePower, .pvPower])
        } catch NetworkError.offline {
        } catch {
            XCTFail()
        }
    }

    func test_fetchReport_returns_tryLater() async {
        config.configureAsLoggedIn()
        stubHTTPResponse(with: "trylater.json")

        do {
            _ = try await sut.fetchReport(variables: [.feedinPower, .gridConsumptionPower, .generationPower, .batChargePower, .pvPower])
        } catch NetworkError.tryLater {
        } catch {
            XCTFail()
        }
    }

    func test_fetchReport_withInvalidToken_requestsToken_andRetriesOriginalFetch() async throws {
        config.configureAsLoggedIn()
        keychainStore.username = "bob"
        keychainStore.hashedPassword = "secrethash"
        stubHTTPResponses(with: ["badtoken.json", "login-success.json", "report-success.json"])

        _ = try await sut.fetchReport(variables: [.feedinPower, .gridConsumptionPower, .generationPower, .batChargePower, .pvPower])
    }
}

extension MockConfig {
    func configureAsLoggedIn() {
        deviceID = "device"
        hasPV = true
        hasBattery = true
    }
}
