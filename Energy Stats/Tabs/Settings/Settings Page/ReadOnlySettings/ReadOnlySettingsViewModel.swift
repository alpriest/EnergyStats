//
//  ReadOnlySettingsViewModel.swift
//
//
//  Created by Alistair Priest on 23/02/2026.
//

import Energy_Stats_Core
import Observation
import SwiftUI

@MainActor
@Observable
final class ReadOnlySettingsViewModel {
    private(set) var configManager: ConfigManaging
    var isReadOnly: Bool = false {
        didSet {
            configManager.isReadOnly = isReadOnly
        }
    }

    var passcode: String = ""
    var alertContent: AlertContent?

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        self.isReadOnly = configManager.isReadOnly
    }

    func updatePasscode(_ newValue: String) {
        let filtered = String(newValue.filter { $0.isNumber }.prefix(4))

        if filtered.count == 4 {
            switch isReadOnly {
            case true:
                if filtered == configManager.readOnlyCode {
                    isReadOnly = false
                    passcode = ""
                    configManager.readOnlyCode = ""
                } else {
                    alertContent = AlertContent(title: "Failed", message: "Passcode was incorrect. Try again.")
                    passcode = ""
                }
            case false:
                configManager.readOnlyCode = filtered
                isReadOnly = true
                passcode = ""
            }
        } else {
            if filtered != passcode {
                passcode = filtered
            }
        }
    }
}
