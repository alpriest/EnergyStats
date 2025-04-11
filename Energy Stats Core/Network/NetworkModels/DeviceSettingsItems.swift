//
//  DeviceSettingsItems.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/04/2025.
//

import Foundation

public enum DeviceSettingsItem: String, RawRepresentable {
    case exportLimit = "ExportLimit"
    case minSoc = "MinSoc"
    case minSocOnGrid = "MinSocOnGrid"
    case maxSoc = "MaxSoc"
    case gridCode = "GridCode"
}

public struct FetchDeviceSettingsItemRequest: Encodable {
    let sn: String
    let key: String
}

public struct FetchDeviceSettingsItemResponse: Decodable {
    public struct Range: Decodable {
        public let min: Double
        public let max: Double
    }

    public let value: String
    public let unit: String
    public let precision: Double
    public let range: Range
}

public struct SetDeviceSettingsItemRequest: Encodable {
    let sn: String
    let key: String
    let value: String
}
