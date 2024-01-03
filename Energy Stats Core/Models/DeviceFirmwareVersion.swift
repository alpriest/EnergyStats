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

public extension Optional where Wrapped == DeviceFirmwareVersion {
    func hasManager(greaterThan other: String) -> Bool {
        guard let self else { return false }

        let components1 = self.manager.split(separator: ".").compactMap { Int($0) }
        let components2 = other.split(separator: ".").compactMap { Int($0) }

        let maxLength = max(components1.count, components2.count)

        for i in 0 ..< maxLength {
            let v1 = components1[safe: i] ?? 0
            let v2 = components2[safe: i] ?? 0

            if v1 > v2 {
                return true
            } else if v1 < v2 {
                return false
            }
        }

        return true
    }
}
