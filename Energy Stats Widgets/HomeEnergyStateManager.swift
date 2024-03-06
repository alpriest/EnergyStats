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
    let network: Networking
    let config: Config

    init() {
        do {
            modelContainer = try ModelContainer(for: BatteryWidgetState.self)
            let keychainStore = KeychainStore()
            config = UserDefaultsConfig()
            network = NetworkService.standard(keychainStore: keychainStore, config: config)
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

        let appSettingsPublisher = AppSettingsPublisherFactory.make(from: config)
        let configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher)

        guard let deviceSN = config.selectedDeviceSN else {
            throw ConfigManager.NoDeviceFoundError()
        }
        guard configManager.hasBattery else {
            throw ConfigManager.NoBattery()
        }

        let real = try await network.fetchRealData(
            deviceSN: deviceSN,
            variables: ["SoC",
                        "batChargePower",
                        "batDischargePower",
                        "batTemperature",
                        "ResidualEnergy"]
        )
        let calculator = BatteryCapacityCalculator(capacityW: configManager.batteryCapacityW,
                                                   minimumSOC: configManager.minSOC,
                                                   bundle: Bundle(for: BundleLocator.self))
        let chargePower = real.datas.currentValue(for: "batChargePower")
        let dischargePower = real.datas.currentValue(for: "batDischargePower")
        let power = chargePower > 0 ? chargePower : -dischargePower

        let viewModel = BatteryViewModel(
            power: power,
            soc: Int(real.datas.currentValue(for: "SoC")),
            residual: real.datas.currentValue(for: "ResidualEnergy") * 10.0,
            temperature: real.datas.currentValue(for: "batTemperature")
        )
        let soc = calculator.effectiveBatteryStateOfCharge(batteryStateOfCharge: viewModel.chargeLevel, includeUnusableCapacity: !configManager.showUsableBatteryOnly)

        let chargeStatusDescription = calculator.batteryChargeStatusDescription(
            batteryChargePowerkWH: viewModel.chargePower,
            batteryStateOfCharge: soc
        )

        try update(soc: Int(soc * 100.0), chargeStatusDescription: chargeStatusDescription)
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
