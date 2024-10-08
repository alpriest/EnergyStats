//
//  StubKeychainStore.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 07/05/2024.
//

import Combine
import Energy_Stats_Core
import Foundation

struct StubKeychainStore: KeychainStoring {
    func store(apiKey: String?, notifyObservers: Bool) throws {}

    func logout() {}

    func updateHasCredentials() {}

    func getToken() -> String? { "863c6969-5d74-450b-b4d4-1c446fb21c81" }

    var hasCredentials = CurrentValueSubject<Bool, Never>(true)

    var isDemoUser: Bool = false

    func getSelectedDeviceSN() -> String? { "66BH3720228D004" }

    func store(selectedDeviceSN: String?) throws {}

    func get(key: KeychainItemKey) -> Bool { false }

    func store(key: KeychainItemKey, value: Bool) throws {}

    func get(key: KeychainItemKey) -> String? {
        switch key {
        case .showGridTotalsOnPowerFlow:
            nil
        case .deviceSN:
            "66BH3720228D004"
        }
    }

    func store(key: KeychainItemKey, value: String?) throws {}
}
