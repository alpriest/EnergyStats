//
//  Credentials.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import Combine
import Foundation
import os

public struct KeychainError: Error {
    init(_ code: OSStatus? = nil) {
        self.code = code
    }

    let code: OSStatus?
}

public enum KeychainItemKey: String {
    case showGridTotalsOnPowerFlow
    case deviceSN
    case batteryCapacity
    case shouldInvertCT2
    case minSOC
    case shouldCombineCT2WithPVPower
    case showUsableBatteryOnly
}

public protocol KeychainStoring {
    func store(apiKey: String?, notifyObservers: Bool) throws
    func logout()
    func updateHasCredentials()
    func getToken() -> String?
    var hasCredentials: CurrentValueSubject<Bool, Never> { get }
    var isDemoUser: Bool { get }
    func store(key: KeychainItemKey, value: Bool) throws
    func store(key: KeychainItemKey, value: String?) throws
    func store(key: KeychainItemKey, value: Double) throws
    func get(key: KeychainItemKey) -> Bool
    func get(key: KeychainItemKey) -> String?
    func get(key: KeychainItemKey) -> Double?
}

public class KeychainStore: KeychainStoring {
    struct KeychainError: Error {
        init(_ code: OSStatus? = nil) {
            self.code = code
        }

        let code: OSStatus?
    }

    public let hasCredentials = CurrentValueSubject<Bool, Never>(false)
    private let group: String

    public init(group: String = "885RLNNNK2.com.alpriest.EnergyStats") {
        self.group = group
        updateHasCredentials()
    }

    public func store(apiKey: String?, notifyObservers: Bool) throws {
        try set(tag: "token", value: apiKey)

        if notifyObservers {
            updateHasCredentials()
        }
    }

    public func getToken() -> String? {
        get(tag: "token")
    }

    public func logout() {
        SecItemDelete(makeQuery(tag: "token"))
        updateHasCredentials()
    }

    public func updateHasCredentials() {
        hasCredentials.value = getToken() != nil
    }

    public var isDemoUser: Bool {
        getToken() == "demo"
    }

    public func get(key: KeychainItemKey) -> String? {
        get(tag: key.rawValue)
    }

    public func store(key: KeychainItemKey, value: String?) throws {
        try set(tag: key.rawValue, value: value)
    }

    public func get(key: KeychainItemKey) -> Bool {
        get(tag: key.rawValue).boolValue
    }

    public func store(key: KeychainItemKey, value: Bool) throws {
        try set(tag: key.rawValue, value: value.stringValue)
    }

    public func get(key: KeychainItemKey) -> Double? {
        guard let result = get(tag: key.rawValue) else { return nil }
        return Double(result)
    }

    public func store(key: KeychainItemKey, value: Double) throws {
        try set(tag: key.rawValue, value: "\(value)")
    }
}

private extension KeychainStore {
    func get(tag: String) -> String? {
        var result: AnyObject?
        let status = SecItemCopyMatching(makeQuery(tag: tag), &result)
        guard status == 0 else {
            return nil
        }

        guard let dict = result as? NSDictionary else { return nil }
        guard let data = dict[kSecValueData] as? Data else { return nil }
        let decoded = String(data: data, encoding: .utf8)

        return decoded
    }

    func makeQuery(tag: String) -> CFDictionary {
        [
            kSecAttrAccessGroup: group,
            kSecAttrApplicationTag: tag,
            kSecClass: kSecClassKey,
            kSecReturnAttributes: true,
            kSecReturnData: true,
            kSecAttrSynchronizable: kCFBooleanTrue!
        ] as [CFString: Any] as CFDictionary
    }

    func set(tag: String, value: String?) throws {
        SecItemDelete(makeQuery(tag: tag))

        try set(tag: tag, data: value?.data(using: .utf8))
    }

    func set(tag: String, data: Data?) throws {
        SecItemDelete(makeQuery(tag: tag))

        if let data {
            let keychainItemQuery = [
                kSecAttrAccessGroup: group,
                kSecAttrApplicationTag: tag,
                kSecValueData: data,
                kSecClass: kSecClassKey,
                kSecAttrSynchronizable: kCFBooleanTrue!
            ] as [CFString: Any] as CFDictionary

            let result = SecItemAdd(keychainItemQuery, nil)
            if result != 0 {
                throw KeychainError(result)
            }
        }
    }
}
