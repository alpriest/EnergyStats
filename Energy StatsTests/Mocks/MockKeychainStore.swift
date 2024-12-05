//
//  MockKeychainStore.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

import Combine
@testable import Energy_Stats
import Energy_Stats_Core
import Foundation

class MockKeychainStore: KeychainStoring {
    var isDemoUser: Bool = true
    var token: String?
    var logoutCalled = false
    var selectedDeviceSN: String?

    func store(apiKey: String?, notifyObservers: Bool) throws {
        token = apiKey
    }

    func logout() {
        logoutCalled = true
        token = nil
    }

    func updateHasCredentials() {
        hasCredentials.value = true
    }

    func getToken() -> String? {
        token
    }

    let hasCredentials = CurrentValueSubject<Bool, Never>(false)

    func store(key: KeychainItemKey, value: Bool) throws {
    }

    func store(key: KeychainItemKey, value: String?) throws {
    }

    func store(key: KeychainItemKey, value: Double) throws {
    }

    func get(key: KeychainItemKey) throws -> Bool {
        false
    }

    func get(key: KeychainItemKey) throws -> String? {
        nil
    }

    func get(key: KeychainItemKey) throws -> Double? {
        nil
    }
}
