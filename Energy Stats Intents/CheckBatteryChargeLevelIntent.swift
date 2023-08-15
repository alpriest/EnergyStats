//
//  CheckBatteryChargeLevelIntent.swift
//  Energy Stats Intents
//
//  Created by Alistair Priest on 15/08/2023.
//

import AppIntents
import Energy_Stats_Core

struct CheckBatteryChargeLevelIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Battery Charge Level"
    static var description: IntentDescription? = "Returns the battery charge level percentage"
    static var authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = KeychainStore()
        let network = Network(credentials: store, store: InMemoryLoggingNetworkStore())
        let config = UserDefaultsConfig()
        guard let deviceID = config.selectedDeviceID else {
            throw ConfigManager.NoDeviceFoundError()
        }
        let battery = try await network.fetchBattery(deviceID: deviceID)

        return .result(value: battery.soc, dialog: IntentDialog(stringLiteral: "\(battery.soc)%"))
    }
}
