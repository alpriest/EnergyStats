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
        public let deviceType: String
    }
}

struct DeviceList: Codable {
    let devices: [Device]
}

public struct Device: Codable, Hashable, Identifiable {
    public let plantName: String
    public let deviceID: String
    public let deviceSN: String
    public let hasPV: Bool
    public let battery: Battery?
    public let deviceType: String?

    public struct Battery: Codable, Hashable {
        let capacity: String?
        let minSOC: String?
    }

    public var id: String { deviceID }

    public var deviceDisplayName: String {
        deviceType ?? "\(deviceID) Re-login to update"
    }
}
