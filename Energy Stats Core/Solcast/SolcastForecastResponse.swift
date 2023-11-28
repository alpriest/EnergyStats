//
//  SolcastForecastResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 13/11/2023.
//

import Foundation

public struct SolcastForecastResponseList: Codable {
    public let forecasts: [SolcastForecastResponse]

    public init(forecasts: [SolcastForecastResponse]) {
        self.forecasts = forecasts
    }
}

public struct SolcastForecastResponse: Codable {
    public let pvEstimate: Double
    public let pvEstimate10: Double
    public let pvEstimate90: Double
    public let periodEnd: Date
    public let period: String

    public init(pvEstimate: Double, pvEstimate10: Double, pvEstimate90: Double, periodEnd: Date, period: String) {
        self.pvEstimate = pvEstimate
        self.pvEstimate10 = pvEstimate10
        self.pvEstimate90 = pvEstimate90
        self.periodEnd = periodEnd
        self.period = period
    }
}

public struct SolcastSiteResponseList: Decodable {
    public let sites: [SolcastSiteResponse]
}

public struct SolcastSiteResponse: Decodable {
    public let name: String
    public let resourceId: String
    public let capacity: Double
    public let longitude: Double
    public let latitude: Double
    public let azimuth: Int
    public let tilt: Int
    public let lossFactor: Double?
    public let dcCapacity: Double?
    public let installDate: Date?

    public init(name: String, resourceId: String, capacity: Double, longitude: Double, latitude: Double, azimuth: Int, tilt: Int, lossFactor: Double?, dcCapacity: Double?, installDate: Date?) {
        self.name = name
        self.resourceId = resourceId
        self.capacity = capacity
        self.longitude = longitude
        self.latitude = latitude
        self.azimuth = azimuth
        self.tilt = tilt
        self.lossFactor = lossFactor
        self.dcCapacity = dcCapacity
        self.installDate = installDate
    }
}
