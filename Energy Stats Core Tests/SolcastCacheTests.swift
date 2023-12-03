//
//  SolcastCacheTests.swift
//  Energy Stats Core Tests
//
//  Created by Alistair Priest on 15/11/2023.
//

@testable import Energy_Stats_Core
import XCTest

final class SolcastCacheTests: XCTestCase {
    func test_MergesExistingTodayContent_WithFreshContent() async throws {
        let existing = SolcastForecastResponseList(forecasts: [
            SolcastForecastResponse(pvEstimate: 110.00, pvEstimate10: 0.5, pvEstimate90: 8.0, periodEnd: .nov_14_2023_1000am, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 110.30, pvEstimate10: 0.5, pvEstimate90: 8.0, periodEnd: .nov_14_2023_1030am, period: "PT30M")
        ])

        let fresh = SolcastForecastResponseList(forecasts: [
            SolcastForecastResponse(pvEstimate: 210.30, pvEstimate10: 2.5, pvEstimate90: 2.0, periodEnd: .nov_14_2023_1030am, period: "PT30M"),
            SolcastForecastResponse(pvEstimate: 211.00, pvEstimate10: 2.5, pvEstimate90: 2.0, periodEnd: .nov_14_2023_1100am, period: "PT30M")
        ])
        let site = SolcastSite.preview()

        let mockFileManager = MockFileManager()
        let mockService = MockSolcast()
        let sut = SolcastCache(service: { mockService },
                               today: { Date.nov_14_2023_1000am },
                               fileManager: mockFileManager)
        mockFileManager.modificationDate = .nov_13_2023_1000am

        mockService.stub = existing
        let result1 = try await sut.fetchForecast(for: site, apiKey: "1")
        XCTAssertEqual(result1.forecasts.map { $0.pvEstimate }, [110.00, 110.30])
        XCTAssertEqual(result1.forecasts.count, 2)

        mockService.stub = fresh
        let result2 = try await sut.fetchForecast(for: site, apiKey: "1")

        XCTAssertEqual(result2.forecasts.map { $0.pvEstimate }, [110.00, 210.30, 211.00])
        XCTAssertEqual(result2.forecasts.count, 3)
    }
}

private extension Date {
    static var nov_13_2023_1000am: Date { Date(timeIntervalSince1970: 1699957800) }
    static var nov_14_2023_1000am: Date { Date(timeIntervalSince1970: 1700042400) }
    static var nov_14_2023_1030am: Date { Date(timeIntervalSince1970: 1700044200) }
    static var nov_14_2023_1100am: Date { Date(timeIntervalSince1970: 1700046000) }
}

private class MockSolcast: SolarForecasting {
    var stub: SolcastForecastResponseList = .init(forecasts: [])
    var siteStub: SolcastSiteResponseList = .init(sites: [])

    func fetchSites(apiKey: String) async throws -> SolcastSiteResponseList {
        siteStub
    }

    func fetchForecast(for site: SolcastSite, apiKey: String) async throws -> SolcastForecastResponseList {
        stub
    }
}

private class MockFileManager: FileManaging {
    var modificationDate: Date = .init()

    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any] {
        [.modificationDate: modificationDate]
    }

    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        FileManager.default.urls(for: directory, in: domainMask)
    }
}
