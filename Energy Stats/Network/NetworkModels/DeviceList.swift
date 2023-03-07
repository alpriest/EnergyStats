//
//  DeviceList.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Foundation

struct DeviceListRequest: Encodable {
    let pageSize = 1
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

struct PagedDeviceListResponse: Decodable {
    let currentPage: Int
    let pageSize: Int
    let total: Int
    let devices: [Device]

    struct Device: Decodable {
        let plantName: String
        let deviceID: String
        let deviceSN: String
        let hasBattery: Bool
        let hasPV: Bool
    }
}

struct DeviceList: Codable {
    let devices: [Device]
}

struct Device: Codable {
    let plantName: String
    let deviceID: String
    let deviceSN: String
    let hasPV: Bool
    let battery: Battery?

    struct Battery: Codable {
        let capacity: String?
        let minSOC: String?
    }
}
