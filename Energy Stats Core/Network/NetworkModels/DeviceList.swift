//
//  DeviceList.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Foundation

struct DeviceListRequest: Encodable {
    let pageSize = 10
    let currentPage = 1
    let total = 0
    let condition = Condition()

    struct Condition: Encodable {
        let queryDate = QueryDate()
    }

    struct QueryDate: Encodable {
        let begin = 0
        let end = 0
    }
}

public struct PagedDeviceListResponse: Decodable, Hashable {
    let currentPage: Int
    let pageSize: Int
    let total: Int
    public let devices: [Device]

    public struct Device: Decodable, Hashable {
        public let plantName: String
        public let deviceID: String
        public let deviceSN: String
        public let hasBattery: Bool
        public let hasPV: Bool
    }
}

struct DeviceList: Codable {
    let devices: [Device]
}

public struct Device: Codable, Hashable {
    public let plantName: String
    public let deviceID: String
    public let deviceSN: String
    public let hasPV: Bool
    public let battery: Battery?

    public struct Battery: Codable, Hashable {
        let capacity: String?
        let minSOC: String?
    }
}
