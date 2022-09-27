//
//  Credentials.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import Foundation

class KeychainStore: ObservableObject {
    struct KeychainError: Error {
        init(_ code: OSStatus? = nil) {
            self.code = code
        }

        let code: OSStatus?
    }

    @Published var hasCredentials = false

    init() {
        updateHasCredentials()
    }

    func getUsername() -> String? {
        get(tag: "username")
    }

    func getHashedPassword() -> String? {
        get(tag: "password")
    }

    func store(username: String, hashedPassword: String) throws {
        logout()

        try set(tag: "password", value: hashedPassword)
        try set(tag: "username", value: username)

        updateHasCredentials()
    }

    func store(token: String?) throws {
        SecItemDelete(makeQuery(tag: "token"))

        try set(tag: "token", value: token)
    }

    func getToken() -> String? {
        get(tag: "token")
    }

    func logout() {
        SecItemDelete(makeQuery(tag: "username"))
        SecItemDelete(makeQuery(tag: "password"))
        updateHasCredentials()
    }
}

private extension KeychainStore {
    func updateHasCredentials() {
        hasCredentials = getUsername() != nil && getHashedPassword() != nil
    }

    func get(tag: String) -> String? {
        var result: AnyObject?
        let status = SecItemCopyMatching(makeQuery(tag: tag), &result)
        guard status == 0 else { return nil }

        guard let dict = result as? NSDictionary else { return nil }
        guard let data = dict[kSecValueData] as? Data else { return nil }
        let decoded = String(data: data, encoding: .utf8)

        return decoded
    }

    func makeQuery(tag: String) -> CFDictionary {
        [
            kSecAttrApplicationTag: tag,
            kSecClass: kSecClassKey,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ] as CFDictionary
    }

    func set(tag: String, value: String?) throws {
        SecItemDelete(makeQuery(tag: tag))

        if let value {
            let keychainItemQuery = [
                kSecAttrApplicationTag: tag,
                kSecValueData: value.data(using: .utf8)!,
                kSecClass: kSecClassKey
            ] as CFDictionary

            let result = SecItemAdd(keychainItemQuery, nil)
            if result != 0 {
                print("AWP", "Could not store \(tag) because \(result)")
                throw KeychainError(result)
            }
        }
    }
}
