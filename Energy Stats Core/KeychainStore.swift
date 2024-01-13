//
//  Credentials.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import Combine
import Foundation

public struct KeychainError: Error {
    init(_ code: OSStatus? = nil) {
        self.code = code
    }

    let code: OSStatus?
}

public protocol KeychainStoring {
    func store(apiKey: String?) throws
    func logout()
    func updateHasCredentials()
    func getToken() -> String?
    var hasCredentials: AnyPublisher<Bool, Never> { get }
    var isDemoUser: Bool { get }
}

public class KeychainStore: KeychainStoring, ObservableObject {
    struct KeychainError: Error {
        init(_ code: OSStatus? = nil) {
            self.code = code
        }

        let code: OSStatus?
    }

    private let hasCredentialsSubject = CurrentValueSubject<Bool, Never>(false)
    public var hasCredentials: AnyPublisher<Bool, Never>

    public init() {
        hasCredentials = hasCredentialsSubject.eraseToAnyPublisher()
        updateHasCredentials()
    }

    public func store(apiKey: String?) throws {
        SecItemDelete(makeQuery(tag: "token"))

        try set(tag: "token", value: apiKey)

        updateHasCredentials()
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
            kSecAttrAccessGroup: "group.com.alpriest.EnergyStats",
            kSecAttrApplicationTag: tag,
            kSecClass: kSecClassKey,
            kSecReturnAttributes: true,
            kSecReturnData: true
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
                kSecAttrAccessGroup: "group.com.alpriest.EnergyStats",
                kSecAttrApplicationTag: tag,
                kSecValueData: data,
                kSecClass: kSecClassKey
            ] as [CFString: Any] as CFDictionary

            let result = SecItemAdd(keychainItemQuery, nil)
            if result != 0 {
                throw KeychainError(result)
            }
        }
    }
}
