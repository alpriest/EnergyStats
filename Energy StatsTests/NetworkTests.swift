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

    override func setUp() {
        keychainStore = MockKeychainStore()
        sut = Network(credentials: keychainStore)
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

    func test_fetchReport_returns_data_on_success() async throws {
        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let stubPath = OHPathForFile("report-success.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
        }

        let report = try await sut.fetchReport(variables: [.feedinPower, .gridConsumptionPower, .generationPower, .batChargePower, .pvPower])

        XCTAssertEqual(report.count, 5)
    }

    func test_fetchReport_throws_when_offline() async {
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
        stub(condition: isHost("www.foxesscloud.com")) { _ in
            let stubPath = OHPathForFile("report-trylater.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type": "application/json"])
        }

        do {
            _ = try await sut.fetchReport(variables: [.feedinPower, .gridConsumptionPower, .generationPower, .batChargePower, .pvPower])
        } catch NetworkError.tryLater {
        } catch {
            XCTFail()
        }
    }
}

private class MockKeychainStore: KeychainStore {
    var username: String?
    var password: String?
    var storedToken: String?

    override func getUsername() -> String? {
        username
    }

    override func getPassword() -> String? {
        password
    }

    override func store(token: String?) throws {
        storedToken = token
    }

    override func store(username: String, password: String) throws {
        self.username = username
        self.password = password
    }
}
