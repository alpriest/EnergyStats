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

public protocol KeychainStoring {
    func store(apiKey: String?, notifyObservers: Bool) throws
    func logout()
    func updateHasCredentials()
    func getToken() -> String?
    var hasCredentials: AnyPublisher<Bool, Never> { get }
    var isDemoUser: Bool { get }
    func getSelectedDeviceSN() -> String?
    func store(selectedDeviceSN: String?) throws
}

public class KeychainStore: KeychainStoring {
    struct KeychainError: Error {
        init(_ code: OSStatus? = nil) {
            self.code = code
        }

        let code: OSStatus?
    }

    private let hasCredentialsSubject = CurrentValueSubject<Bool, Never>(false)
    public var hasCredentials: AnyPublisher<Bool, Never>
    private let group: String

    public func getSelectedDeviceSN() -> String? {
        get(tag: "deviceSN")
    }

    public func store(selectedDeviceSN: String?) throws {
        guard let selectedDeviceSN else { return }

        try set(tag: "deviceSN", value: selectedDeviceSN)
    }

    public init(group: String = "885RLNNNK2.com.alpriest.EnergyStats") {
        self.group = group
        hasCredentials = hasCredentialsSubject.eraseToAnyPublisher()
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
        SecItemDelete(makeQuery(tag: "username"))
        SecItemDelete(makeQuery(tag: "password"))
        SecItemDelete(makeQuery(tag: "token"))
        updateHasCredentials()
    }

    public func updateHasCredentials() {
        hasCredentialsSubject.send(getToken() != nil)
    }

    public var isDemoUser: Bool {
        getToken() == "demo"
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

        if let value {
            try set(tag: tag, data: value.data(using: .utf8))
        }
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

public extension KeychainStore {
    static func mock() -> KeychainStoring {
        MockKeychainStore()
    }
}

class MockKeychainStore: KeychainStoring {
    var isDemoUser: Bool = true
    var hashedPassword: String?
    var token: String?
    var logoutCalled = false
    var selectedDeviceSN: String? = "abc-123-def-123-ghi-123-jkl"

    func getHashedPassword() -> String? {
        hashedPassword
    }

    func store(apiKey: String?, notifyObservers: Bool) throws {
        token = apiKey
    }

    func getToken() -> String? {
        token
    }

    func logout() {
        logoutCalled = true
    }

    func updateHasCredentials() {}

    let hasCredentialsSubject = CurrentValueSubject<Bool, Never>(false)
    let hasCredentials: AnyPublisher<Bool, Never>

    init() {
        hasCredentials = hasCredentialsSubject.eraseToAnyPublisher()
    }

    func updateHasCredentials(value: Bool) {
        hasCredentialsSubject.send(value)
    }

    public func store(selectedDeviceSN: String?) throws {
        self.selectedDeviceSN = selectedDeviceSN
    }

    public func getSelectedDeviceSN() -> String? {
        selectedDeviceSN
    }
}
