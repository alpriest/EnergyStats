//
//  PowerStationDetailResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/03/2024.
//

import Foundation

public struct PagedStationListResponse: Decodable, Hashable {
    let currentPage: Int
    let pageSize: Int
    let total: Int
    public let data: [PowerStationSummaryResponse]
}

public struct PowerStationSummaryResponse: Decodable, Hashable {
    public let stationID: String
}

public struct PowerStationDetailResponse: Decodable {
    public let stationName: String
    public let capacity: Double
    public let ianaTimezone: String
}
