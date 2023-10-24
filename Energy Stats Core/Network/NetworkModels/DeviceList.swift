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

public struct PagedDeviceListResponse: Codable, Hashable {
    let currentPage: Int
    let pageSize: Int
    let total: Int
    public let devices: [Device]

    public struct Device: Codable, Hashable {
        public let plantName: String
        public let deviceID: String
        public let deviceSN: String
        public let moduleSN: String
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
    public let hasBattery: Bool
    public let deviceType: String?
    public let firmware: DeviceFirmwareVersion?
    public let variables: [RawVariable]
    public let moduleSN: String

    public struct Battery: Codable, Hashable {
        public let capacity: String?
        public let minSOC: String?

        public init(capacity: String?, minSOC: String?) {
            self.capacity = capacity
            self.minSOC = minSOC
        }
    }

    public var id: String { deviceID }

    public var deviceDisplayName: String {
        deviceType ?? "\(deviceID) Re-login to update"
    }

    public var deviceSelectorName: String {
        "\(deviceDisplayName) \(plantName)"
    }

    public init(plantName: String,
                deviceID: String,
                deviceSN: String,
                hasPV: Bool,
                hasBattery: Bool,
                battery: Battery?,
                deviceType: String?,
                firmware: DeviceFirmwareVersion?,
                variables: [RawVariable],
                moduleSN: String)
    {
        self.plantName = plantName
        self.deviceID = deviceID
        self.deviceSN = deviceSN
        self.hasPV = hasPV
        self.hasBattery = hasBattery
        self.battery = battery
        self.deviceType = deviceType
        self.firmware = firmware
        self.variables = variables
        self.moduleSN = moduleSN
    }

    public func copy(plantName: String? = nil,
                     deviceID: String? = nil,
                     deviceSN: String? = nil,
                     hasPV: Bool? = nil,
                     hasBattery: Bool? = nil,
                     battery: Battery? = nil,
                     deviceType: String? = nil,
                     firmware: DeviceFirmwareVersion? = nil,
                     variables: [RawVariable]? = nil,
                     moduleSN: String? = nil) -> Device
    {
        Device(
            plantName: plantName ?? self.plantName,
            deviceID: deviceID ?? self.deviceID,
            deviceSN: deviceSN ?? self.deviceSN,
            hasPV: hasPV ?? self.hasPV,
            hasBattery: hasBattery ?? self.hasBattery,
            battery: battery ?? self.battery,
            deviceType: deviceType ?? self.deviceType,
            firmware: firmware ?? self.firmware,
            variables: variables ?? self.variables,
            moduleSN: moduleSN ?? self.moduleSN
        )
    }
}
