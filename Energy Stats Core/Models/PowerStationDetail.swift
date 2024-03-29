//
//  PowerStationDetail.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 06/03/2024.
//

import Foundation

public struct PowerStationDetail: Codable {
    public let stationName: String
    public let capacity: Double
    public let timezone: String

    public init(stationName: String, capacity: Double, timezone: String) {
        self.stationName = stationName
        self.capacity = capacity
        self.timezone = timezone
    }
}
