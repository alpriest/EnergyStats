//
//  InverterWorkModeResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 07/08/2023.
//

import Foundation

public struct DeviceSettingsSetRequest: Encodable {
    public let id: String
    public let key: DeviceSettingsCodingKeys
    public let values: InverterValues
}

public struct DeviceSettingsGetRequest: Decodable {
    public let `protocol`: String
    public let raw: String
    public let values: InverterValues
}

public enum DeviceSettingsCodingKeys: String, CodingKey, Encodable {
    case operationModeWorkMode = "operation_mode__work_mode"
}

public struct InverterValues: Codable {
    public let operationModeWorkMode: InverterWorkMode

    init(operationModeWorkMode: InverterWorkMode) {
        self.operationModeWorkMode = operationModeWorkMode
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DeviceSettingsCodingKeys.self)
        self.operationModeWorkMode = try container.decode(InverterWorkMode.self, forKey: .operationModeWorkMode)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DeviceSettingsCodingKeys.self)
        try container.encode(self.operationModeWorkMode, forKey: .operationModeWorkMode)
    }
}

public enum InverterWorkMode: String, Codable {
    case selfUse = "SelfUse"
    case feedInFirst = "Feedin"
    case backup = "Backup"
    case powerStation = "PowerStation"
    case peakShaving = "PeakShaving"

    public func asWorkMode() -> WorkMode {
        switch self {
        case .selfUse:
            return .selfUse
        case .feedInFirst:
            return .feedInFirst
        case .backup:
            return .backup
        case .powerStation:
            return .powerStation
        case .peakShaving:
            return .peakShaving
        }
    }
}
