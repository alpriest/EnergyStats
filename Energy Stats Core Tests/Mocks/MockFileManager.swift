//
//  MockFileManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/02/2025.
//

@testable import Energy_Stats_Core
import XCTest

public class MockFileManager: FileManaging {
    var modificationDate: Date = .init()

    public func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any] {
        [.modificationDate: modificationDate]
    }

    public func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        FileManager.default.urls(for: directory, in: domainMask)
    }

    public func removeItem(at url: URL) throws {}
}
