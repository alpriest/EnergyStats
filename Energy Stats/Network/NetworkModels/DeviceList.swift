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

struct DeviceListResponse: Decodable {
    let errno: Int
    let result: PagedDevices

    struct PagedDevices: Decodable {
        let currentPage: Int
        let pageSize: Int
        let total: Int
        let devices: [Device]
    }

    struct Device: Decodable {
        let deviceID: String
        let hasBattery: Bool
        let hasPV: Bool
    }
}
