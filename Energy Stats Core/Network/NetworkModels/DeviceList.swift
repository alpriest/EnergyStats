//
//  DeviceList.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Foundation

struct DeviceListRequest: Encodable {
    let pageSize = 20
    let currentPage = 1

    struct QueryDate: Encodable {
        let begin = 0
        let end = 0
    }
}

public struct PagedDeviceListResponse: Codable, Hashable {
    let currentPage: Int
    let pageSize: Int
    let total: Int
    public let data: [Device]

    public struct Device: Codable, Hashable {
        public let deviceSN: String
        public let moduleSN: String
        public let plantID: String
        public let status: Int
    }
}

public struct DeviceDetailResponse: Codable, Hashable {
    public let deviceSN: String
    public let moduleSN: String
    public let stationID: String
    public let stationName: String
    public let managerVersion: String
    public let masterVersion: String
    public let slaveVersion: String
    public let hardwareVersion: String
    public let status: Int
    public let function: Function

    public struct Function: Codable, Hashable {
        public let scheduler: Bool
    }
}

struct DeviceList: Codable {
    let devices: [Device]
}

public struct Device: Codable, Hashable, Identifiable {
    public let deviceSN: String
    public let stationName: String
    public let stationID: String
    public let battery: Battery?
    public let firmware: DeviceFirmwareVersion?
    public let moduleSN: String

    public struct Battery: Codable, Hashable {
        public let capacity: String?
        public let minSOC: String?

        public init(capacity: String?, minSOC: String?) {
            self.capacity = capacity
            self.minSOC = minSOC
        }
    }

    public var id: String { deviceSN }

    public var deviceDisplayName: String {
        "\(stationName) \(stationID)"
    }

    public var deviceSelectorName: String {
        stationName
    }

    public init(deviceSN: String,
                stationName: String,
                stationID: String,
                battery: Battery?,
                firmware: DeviceFirmwareVersion?,
                moduleSN: String)
    {
        self.deviceSN = deviceSN
        self.stationName = stationName
        self.stationID = stationID
        self.battery = battery
        self.firmware = firmware
        self.moduleSN = moduleSN
    }

    public func copy(deviceSN: String? = nil,
                     stationName: String? = nil,
                     stationID: String? = nil,
                     battery: Battery? = nil,
                     firmware: DeviceFirmwareVersion? = nil,
                     moduleSN: String? = nil) -> Device
    {
        Device(
            deviceSN: deviceSN ?? self.deviceSN,
            stationName: stationName ?? self.stationName,
            stationID: stationID ?? self.stationID,
            battery: battery ?? self.battery,
            firmware: firmware ?? self.firmware,
            moduleSN: moduleSN ?? self.moduleSN
        )
    }
}
