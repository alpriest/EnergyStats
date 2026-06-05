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

    public func fileExists(atPath path: String) -> Bool {
        false
    }

    public func contents(atPath path: String) -> Data? {
        nil
    }

    public func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey: Any]?) -> Bool {
        true
    }

    public func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]?) throws {}
}
