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

    func getSelectedDeviceSN() -> String? {
        selectedDeviceSN
    }

    func store(selectedDeviceSN: String?) throws {
        self.selectedDeviceSN = selectedDeviceSN
    }
}
