//
//  PowerStationDetailResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/03/2024.
//

import Foundation

struct PowerStationListRequest: Encodable {
    let currentPage: Int = 1
    let pageSize: Int = 100
}

struct PagedPowerStationListResponse: Codable, Hashable {
    let currentPage: Int
    let pageSize: Int
    let total: Int
    public let data: [PowerStationSummaryResponse]
}

struct PowerStationSummaryResponse: Codable, Hashable {
    public let stationID: String
}

struct PowerStationDetailResponse: Codable {
    public let stationName: String
    public let capacity: Double
    public let timezone: String
}

extension PowerStationDetailResponse {
    func toPowerStationDetail() -> PowerStationDetail {
        PowerStationDetail(
            stationName: stationName,
            capacity: capacity,
            timezone: timezone
        )
    }
}
