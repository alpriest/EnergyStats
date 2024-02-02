//
//  PreviewKeychainStore.swift
//  Energy Stats
//
//  Created by Alistair Priest on 31/01/2024.
//

import Combine
import Energy_Stats_Core
import Foundation

class PreviewKeychainStore: KeychainStoring {
    var isDemoUser: Bool = true
    var hashedPassword: String?
    var token: String? = "abc-123-def-123-ghi-123-jkl"
    var logoutCalled = false

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
}
