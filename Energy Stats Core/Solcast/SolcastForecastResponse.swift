//
//  SolcastForecastResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 13/11/2023.
//

import Foundation

public struct SolcastForecastResponseList: Decodable {
    public let forecasts: [SolcastForecastResponse]
}

public struct SolcastForecastResponse: Decodable {
    public let pv_estimate: Double
    public let pv_estimate10: Double
    public let pv_estimate90: Double
    public let period_end: Date
}
