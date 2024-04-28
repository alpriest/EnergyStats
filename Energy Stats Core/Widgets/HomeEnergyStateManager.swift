//
//  Intents.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 24/09/2023.
//

import AppIntents
import SwiftData
import WidgetKit

@available(iOS 17.0, *)
@available(watchOS 9.0, *)
public class HomeEnergyStateManager {
    public static var shared: HomeEnergyStateManager = .init()

    public let modelContainer: ModelContainer
    let network: Networking
    let config: Config
    let keychainStore = KeychainStore()

    init() {
        do {
            modelContainer = try ModelContainer(for: BatteryWidgetState.self)
            config = UserDefaultsConfig()
            network = NetworkService.standard(keychainStore: keychainStore, config: config)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }

    @MainActor
    public func isStale() async -> Bool {
        let fetchDescriptor: FetchDescriptor<BatteryWidgetState> = FetchDescriptor()
        guard let widgetState = (try? modelContainer.mainContext.fetch(fetchDescriptor))?.first else { return true }

        return widgetState.lastUpdated.timeIntervalSinceNow < -60
    }

    @MainActor
    public func update() async throws {
        guard await isStale() else { return }

        let appSettingsPublisher = AppSettingsPublisherFactory.make(from: config)
        let configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher, keychainStore: keychainStore)

        guard let deviceSN = keychainStore.selectedDeviceSN else {
            throw ConfigManager.NoDeviceFoundError()
        }

        let real = try await network.fetchRealData(
            deviceSN: deviceSN,
            variables: ["SoC",
                        "SoC_1",
                        "batChargePower",
                        "batDischargePower",
                        "batTemperature",
                        "ResidualEnergy"]
        )
        let calculator = BatteryCapacityCalculator(capacityW: configManager.batteryCapacityW,
                                                   minimumSOC: configManager.minSOC,
                                                   bundle: Bundle(for: BundleLocator.self))
        let chargePower = real.datas.currentDouble(for: "batChargePower")
        let dischargePower = real.datas.currentDouble(for: "batDischargePower")
        let power = chargePower > 0 ? chargePower : -dischargePower

        let viewModel = BatteryViewModel(
            power: power,
            soc: Int(real.datas.SoC()),
            residual: real.datas.currentDouble(for: "ResidualEnergy") * 10.0,
            temperature: real.datas.currentDouble(for: "batTemperature")
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
