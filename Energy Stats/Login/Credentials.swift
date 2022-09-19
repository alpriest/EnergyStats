//
//  Credentials.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2022.
//

import Foundation

class KeychainStore: ObservableObject {
    struct KeychainError: Error {}
    private let server = "energystats"

    @Published var hasCredentials = false

    init() {
        self.hasCredentials = getUsername() != nil && getPassword() != nil
    }

    private var query: CFDictionary {
        [
            kSecAttrServer: server,
            kSecClass: kSecClassInternetPassword,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ] as CFDictionary
    }

    func getUsername() -> String? {
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        guard status == 0 else { return nil }

        guard let dict = result as? NSDictionary else { return nil }
        guard let username = dict[kSecAttrAccount] as? String else { return nil }

        return username
    }

    func getPassword() -> String? {
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        guard status == 0 else { return nil }

        guard let dict = result as? NSDictionary else { return nil }
        guard let passwordData = dict[kSecValueData] as? Data else { return nil }
        let password = String(data: passwordData, encoding: .utf8)

        return password
    }

    func store(username: String, password: String) throws {
        guard let hashed = password.md5() else {
            throw KeychainError()
        }

        let keychainItemQuery = [
            kSecValueData: hashed.data(using: .utf8)!,
            kSecAttrAccount: username,
            kSecAttrServer: server,
            kSecClass: kSecClassInternetPassword
        ] as CFDictionary

        if SecItemAdd(keychainItemQuery, nil) != 0 {
            throw KeychainError()
        }
    }

    func logout() {
        SecItemDelete(query)
        hasCredentials = false
    }
}
