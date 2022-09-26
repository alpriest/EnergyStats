//
//  NetworkTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 25/09/2022.
//

@testable import Energy_Stats
import OHHTTPStubs
import OHHTTPStubsSwift
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
        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let stubPath = OHPathForFile("login-success.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
        }

        try await sut.verifyCredentials(username: "bob", hashedPassword: "secret")
    }

    func test_verifyCredentials_throws_on_failure() async throws {
        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let stubPath = OHPathForFile("login-failure.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
        }

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
        keychainStore.password = "secret"

        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let stubPath = OHPathForFile("login-success.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
        }

        await sut.ensureTokenValid()

        XCTAssertNotNil(keychainStore.token)
    }

    func test_ensureTokenValid_fetches_device_list_if_token_present() async throws {
        keychainStore.token = "token"

        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let stubPath = OHPathForFile("devicelist-success.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
        }

        await sut.ensureTokenValid()

        XCTAssertNotNil(keychainStore.token)
    }

    func test_fetchReport_returns_data_on_success() async throws {
        config.configureAsLoggedIn()
        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let stubPath = OHPathForFile("report-success.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
        }

        let report = try await sut.fetchReport(variables: [.feedinPower, .gridConsumptionPower, .generationPower, .batChargePower, .pvPower])

        XCTAssertEqual(report.count, 5)
    }

    func test_fetchBattery_returns_data_on_success() async throws {
        config.configureAsLoggedIn()
        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let stubPath = OHPathForFile("battery-success.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
        }

        let report = try await sut.fetchBattery()

        XCTAssertEqual(report.power, -1.065)
        XCTAssertEqual(report.soc, 23)
    }

    func test_fetchRaw_returns_data_on_success() async throws {
        config.configureAsLoggedIn()
        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let stubPath = OHPathForFile("raw-success.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
        }

        let report = try await sut.fetchRaw(variables: [.feedinPower, .gridConsumptionPower, .pvPower, .loadsPower])

        XCTAssertEqual(report.count, 4)
    }

    func test_fetchDeviceList_returns_data_on_success() async throws {
        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let stubPath = OHPathForFile("devicelist-success.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
        }

        let report = try await sut.fetchDeviceList()

        XCTAssertEqual(report.devices.first?.hasBattery, true)
        XCTAssertEqual(report.devices.first?.deviceID, "03274209-486c-4ea3-9c28-159f25ee84cb")
    }

    func test_fetchReport_throws_when_offline() async {
        config.configureAsLoggedIn()
        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
            return HTTPStubsResponse(error: notConnectedError)
        }

        do {
            _ = try await sut.fetchReport(variables: [.feedinPower, .gridConsumptionPower, .generationPower, .batChargePower, .pvPower])
        } catch NetworkError.offline {
        } catch {
            XCTFail()
        }
    }

    func test_fetchReport_returns_tryLater() async {
        config.configureAsLoggedIn()
        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let stubPath = OHPathForFile("trylater.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
        }

        do {
            _ = try await sut.fetchReport(variables: [.feedinPower, .gridConsumptionPower, .generationPower, .batChargePower, .pvPower])
        } catch NetworkError.tryLater {
        } catch {
            XCTFail()
        }
    }

    func test_fetchReport_withInvalidToken_requestsToken_andRetriesOriginalFetch() async throws {
        config.configureAsLoggedIn()
        var callCount = 0
        keychainStore.username = "bob"
        keychainStore.password = "secret"

        stub(condition: isHost("www.foxesscloud.com")) { _ in
            callCount += 1
            print("AWP", callCount)
            if callCount == 1 {
                let stubPath = OHPathForFile("badtoken.json", type(of: self))
                return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
            } else if callCount == 2 {
                let stubPath = OHPathForFile("login-success.json", type(of: self))
                return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
            } else {
                let stubPath = OHPathForFile("report-success.json", type(of: self))
                return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
            }
        }

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
