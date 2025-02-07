//
//  MockSolcast.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/02/2025.
//

import Energy_Stats_Core

public class MockSolcast: SolcastFetching {
    var stubForecastResponseList: SolcastForecastResponseList = .init(forecasts: [])
    var siteStub: SolcastSiteResponseList = .init(sites: [])
    var stubSolcastForecastList: SolcastForecastList = .init(tooManyRequests: false, forecasts: [])

    public func fetchSites(apiKey: String) async throws -> SolcastSiteResponseList {
        siteStub
    }

    public func fetchForecast(for site: SolcastSite, apiKey: String) async throws -> SolcastForecastResponseList {
        stubForecastResponseList
    }
}

extension MockSolcast: SolcastCaching {
    public func fetchForecast(for site: SolcastSite, apiKey: String, ignoreCache: Bool) async throws -> SolcastForecastList {
        stubSolcastForecastList
    }
}
