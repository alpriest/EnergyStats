//
//  DeviceFirmwareVersion.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/04/2023.
//

import Foundation

public struct DeviceFirmwareVersion: Codable, Equatable, Hashable {
    public let master: String
    public let slave: String
    public let manager: String

    public init(master: String, slave: String, manager: String) {
        self.master = master
        self.slave = slave
        self.manager = manager
    }
}

public extension DeviceFirmwareVersion {
    static func preview() -> DeviceFirmwareVersion {
        DeviceFirmwareVersion(master: "1.54", slave: "1.01", manager: "1.27")
    }
}
