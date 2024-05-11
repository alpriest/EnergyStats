//
//  MockKeychainStore.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 11/05/2024.
//

import Combine
import Foundation

public extension KeychainStore {
    static func mock() -> KeychainStoring {
        MockKeychainStore()
    }

    static func preview() -> KeychainStoring {
        MockKeychainStore()
    }
}

class MockKeychainStore: KeychainStoring {
    var isDemoUser: Bool = true
    var apiKey: String?
    var logoutCalled = false
    var selectedDeviceSN: String? = "abc-123-def-123-ghi-123-jkl"

    func store(apiKey: String?, notifyObservers: Bool) throws {
        self.apiKey = apiKey
    }

    func getToken() -> String? {
        apiKey
    }

    func logout() {
        logoutCalled = true
    }

    func updateHasCredentials() {}

    let hasCredentials = CurrentValueSubject<Bool, Never>(false)

    func updateHasCredentials(value: Bool) {
        hasCredentials.value = value
    }

    public func store(selectedDeviceSN: String?) throws {
        self.selectedDeviceSN = selectedDeviceSN
    }

    public func getSelectedDeviceSN() -> String? {
        selectedDeviceSN
    }
}
