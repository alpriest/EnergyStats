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
    public let pv_estimate: Double
    public let pv_estimate10: Double
    public let pv_estimate90: Double
    public let period_end: Date
    public let period: String

    public init(pv_estimate: Double, pv_estimate10: Double, pv_estimate90: Double, period_end: Date, period: String) {
        self.pv_estimate = pv_estimate
        self.pv_estimate10 = pv_estimate10
        self.pv_estimate90 = pv_estimate90
        self.period_end = period_end
        self.period = period
    }
}

public struct SolcastSiteResponseList: Decodable {
    public let sites: [SolcastSiteResponse]
}

public struct SolcastSiteResponse: Decodable {
    public let name: String?
    public let resourceId: String
    public let capacity: Double
    public let longitude: Double
    public let latitude: Double
    public let azimuth: Int
    public let tilt: Int
    public let lossFactor: Double

    public init(name: String?, resourceId: String, capacity: Double, longitude: Double, latitude: Double, azimuth: Int, tilt: Int, lossFactor: Double) {
        self.name = name
        self.resourceId = resourceId
        self.capacity = capacity
        self.longitude = longitude
        self.latitude = latitude
        self.azimuth = azimuth
        self.tilt = tilt
        self.lossFactor = lossFactor
    }
}
