//
//  MockSolcast.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/02/2025.
//

@testable import Energy_Stats_Core
import XCTest

public class MockSolcast: SolcastFetching {
    var stub: SolcastForecastResponseList = .init(forecasts: [])
    var siteStub: SolcastSiteResponseList = .init(sites: [])

    public func fetchSites(apiKey: String) async throws -> SolcastSiteResponseList {
        siteStub
    }

    public func fetchForecast(for site: SolcastSite, apiKey: String) async throws -> SolcastForecastResponseList {
        stub
    }
}
