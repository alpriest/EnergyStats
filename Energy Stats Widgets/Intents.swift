//
//  Intents.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 24/09/2023.
//

import AppIntents
import Energy_Stats_Core
import Foundation
import WidgetKit

class HomeEnergyStateManager {
    static var shared: HomeEnergyStateManager = .init()

    private(set) var batterySOC: Int = 0
    private(set) var lastUpdated: Date = .distantPast
    private(set) var chargeStatusDescription: String?

    private func update(soc: Int, chargeStatusDescription: String?) {
        batterySOC = soc
        self.chargeStatusDescription = chargeStatusDescription
        lastUpdated = .now
    }

    var isStale: Bool {
        lastUpdated.timeIntervalSinceNow < -60
    }

    func update() async throws {
        guard isStale else { return }

        let keychainStore = KeychainStore()
        let config = UserDefaultsConfig()
        let store = InMemoryLoggingNetworkStore()
        let network = NetworkFacade(network: NetworkCache(network: Network(credentials: keychainStore, store: store)),
                                    config: config,
                                    store: keychainStore)
        let configManager = ConfigManager(networking: network, config: config)

        guard let deviceID = config.selectedDeviceID else {
            throw ConfigManager.NoDeviceFoundError()
        }
        let battery = try await network.fetchBattery(deviceID: deviceID)
        let calculator = BatteryCapacityCalculator(capacityW: configManager.batteryCapacityW,
                                                   minimumSOC: configManager.minSOC)
        let viewModel = BatteryViewModel(from: battery)
        let chargeStatusDescription = calculator.batteryChargeStatusDescription(batteryChargePowerkWH: viewModel.chargePower, batteryStateOfCharge: viewModel.chargeLevel)

        update(soc: battery.soc + ([1, 5, 10].randomElement() ?? 1),
               chargeStatusDescription: chargeStatusDescription)
    }
}

@available(iOS 16.0, *)
struct UpdateBatteryChargeLevelIntent: AppIntent {
    static var title: LocalizedStringResource = "Update Storage Battery SOC for the widget"
    static var authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some ReturnsValue<Bool> {
        do {
            try await HomeEnergyStateManager.shared.update()

            WidgetCenter.shared.reloadTimelines(ofKind: "BatteryWidget")

            return .result(value: true)
        } catch {
            return .result(value: false)
        }

//        return .result(value: battery.soc)
    }
}
