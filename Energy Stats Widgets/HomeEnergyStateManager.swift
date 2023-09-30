//
//  Intents.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 24/09/2023.
//

import AppIntents
import Energy_Stats_Core
import Foundation
import SwiftData
import WidgetKit

class HomeEnergyStateManager {
    static var shared: HomeEnergyStateManager = .init()

    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: BatteryWidgetState.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }

    @MainActor
    func isStale() async -> Bool {
        let fetchDescriptor: FetchDescriptor<BatteryWidgetState> = FetchDescriptor()
        guard let widgetState = (try? modelContainer.mainContext.fetch(fetchDescriptor))?.first else { return true }

        return widgetState.lastUpdated.timeIntervalSinceNow < -60
    }

    @MainActor
    func update() async throws {
        guard await isStale() else { return }

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
        guard configManager.hasBattery else {
            throw ConfigManager.NoBattery()
        }
        let battery = try await network.fetchBattery(deviceID: deviceID)
        let calculator = BatteryCapacityCalculator(capacityW: configManager.batteryCapacityW,
                                                   minimumSOC: configManager.minSOC,
                                                   bundle: Bundle(for: BundleLocator.self))
        let viewModel = BatteryViewModel(from: battery)
        let chargeStatusDescription = calculator.batteryChargeStatusDescription(batteryChargePowerkWH: viewModel.chargePower, batteryStateOfCharge: viewModel.chargeLevel)

        try update(soc: battery.soc, chargeStatusDescription: chargeStatusDescription)
    }

    @MainActor
    private func update(soc: Int, chargeStatusDescription: String?) throws {
        let state = BatteryWidgetState(batterySOC: soc, chargeStatusDescription: chargeStatusDescription)

        deleteEntry()

        modelContainer.mainContext.insert(state)
        modelContainer.mainContext.processPendingChanges()
    }

    @MainActor
    private func deleteEntry() {
        let fetchDescriptor: FetchDescriptor<BatteryWidgetState> = FetchDescriptor()
        if let widgetState = (try? modelContainer.mainContext.fetch(fetchDescriptor))?.first {
            modelContainer.mainContext.delete(widgetState)
        }
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
    }
}
