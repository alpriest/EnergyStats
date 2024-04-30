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
    var apiKey: String? = "abc-123-def-123-ghi-123-jkl"
    var logoutCalled = false
    var selectedDeviceSN: String? = "abc-123-def-123-ghi-123-jkl"

    public func store(selectedDeviceSN: String?) throws {
        self.selectedDeviceSN = selectedDeviceSN
    }

    public func getSelectedDeviceSN() -> String? {
        selectedDeviceSN
    }

    public func store(apiKey: String?, notifyObservers: Bool) throws {
        self.apiKey = apiKey
    }

    public func getToken() -> String? {
        apiKey
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
