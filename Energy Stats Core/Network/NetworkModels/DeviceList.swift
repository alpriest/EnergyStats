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
}

public struct PagedDeviceListResponse: Codable, Hashable {
    let currentPage: Int
    let pageSize: Int
    let total: Int
    public let data: [DeviceSummaryResponse]
}

public struct DeviceSummaryResponse: Codable, Hashable {
    public let deviceSN: String
    public let moduleSN: String
    public let stationID: String
    public let stationName: String
    public let productType: String
    public let deviceType: String
    public let hasBattery: Bool
    public let hasPV: Bool
    public let status: Int
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
    public let productType: String
    public let deviceType: String
    public let hasBattery: Bool
    public let hasPV: Bool
    public let batteryList: [DeviceBatteryResponse]?

    public struct Function: Codable, Hashable {
        public let scheduler: Bool
    }
}

public struct DeviceBatteryResponse: Codable, Hashable {
    public let batterySN: String
    public let type: String
    public let version: String
}

struct DeviceList: Codable {
    let devices: [Device]
}

public struct Device: Codable, Hashable, Identifiable {
    public let deviceSN: String
    public let hasPV: Bool
    public let stationName: String?
    public let stationID: String
    public let hasBattery: Bool
    public let deviceType: String
    public let battery: Battery?
    public let moduleSN: String
    public let productType: String?

    public struct Battery: Codable, Hashable {
        public let capacity: String?
        public let minSOC: String?
        public let modules: [DeviceBatteryModule]?

        public init(capacity: String?, minSOC: String?, modules: [DeviceBatteryModule]?) {
            self.capacity = capacity
            self.minSOC = minSOC
            self.modules = modules
        }

        public func copy(capacity: String? = nil, minSOC: String? = nil) -> Self {
            Self(
                capacity: capacity ?? self.capacity,
                minSOC: minSOC ?? self.minSOC,
                modules: modules
            )
        }
    }

    public var id: String { deviceSN }

    public var deviceDisplayName: String {
        "\(deviceType) \(deviceSN)"
    }

    public var deviceSelectorName: String {
        stationName ?? deviceSN
    }

    public init(deviceSN: String,
                stationName: String?,
                stationID: String,
                battery: Battery?,
                moduleSN: String,
                deviceType: String,
                hasPV: Bool,
                hasBattery: Bool,
                productType: String?)
    {
        self.deviceSN = deviceSN
        self.stationName = stationName
        self.stationID = stationID
        self.battery = battery
        self.moduleSN = moduleSN
        self.deviceType = deviceType
        self.hasPV = hasPV
        self.hasBattery = hasBattery
        self.productType = productType
    }

    public func copy(deviceSN: String? = nil,
                     stationName: String? = nil,
                     stationID: String? = nil,
                     battery: Battery? = nil,
                     moduleSN: String? = nil,
                     deviceType: String? = nil,
                     hasPV: Bool? = nil,
                     hasBattery: Bool? = nil,
                     productType: String? = nil) -> Device
    {
        Device(
            deviceSN: deviceSN ?? self.deviceSN,
            stationName: stationName ?? self.stationName,
            stationID: stationID ?? self.stationID,
            battery: battery ?? self.battery,
            moduleSN: moduleSN ?? self.moduleSN,
            deviceType: deviceType ?? self.deviceType,
            hasPV: hasPV ?? self.hasPV,
            hasBattery: hasBattery ?? self.hasBattery,
            productType: productType ?? self.productType
        )
    }
}

public struct DeviceBatteryModule: Codable, Hashable, Identifiable {
    public var id: String { batterySN + type + version }
    public let batterySN: String
    public let type: String
    public let version: String

    public init(batterySN: String, type: String, version: String) {
        self.batterySN = batterySN
        self.type = type
        self.version = version
    }
}
