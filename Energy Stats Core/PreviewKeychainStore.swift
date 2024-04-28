//
//  PreviewKeychainStore.swift
//  Energy Stats
//
//  Created by Alistair Priest on 31/01/2024.
//

import Combine
import Foundation

public class PreviewKeychainStore: KeychainStoring {
    public var isDemoUser: Bool = true
    var token: String? = "abc-123-def-123-ghi-123-jkl"
    var logoutCalled = false
    public var selectedDeviceSN: String?

    public func store(apiKey: String?, notifyObservers: Bool) throws {
        token = apiKey
    }

    public func getToken() -> String? {
        token
    }

    public func logout() {
        logoutCalled = true
    }

    public func updateHasCredentials() {}

    let hasCredentialsSubject = CurrentValueSubject<Bool, Never>(false)
    public let hasCredentials: AnyPublisher<Bool, Never>

    public init() {
        hasCredentials = hasCredentialsSubject.eraseToAnyPublisher()
    }
}
