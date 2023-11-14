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

    public init(pv_estimate: Double, pv_estimate10: Double, pv_estimate90: Double, period_end: Date) {
        self.pv_estimate = pv_estimate
        self.pv_estimate10 = pv_estimate10
        self.pv_estimate90 = pv_estimate90
        self.period_end = period_end
    }
}
