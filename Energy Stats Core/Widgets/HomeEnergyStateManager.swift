//
//  Intents.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 24/09/2023.
//

import AppIntents
import SwiftData
import WidgetKit

public protocol HomeEnergyStateManagerConfig {
    var batteryCapacityW: Int { get }
    var minSOC: Double { get }
    var showUsableBatteryOnly: Bool { get }
    var selectedDeviceSN: String? { get }
    var dataCeiling: DataCeiling { get }
    var isDemoUser: Bool { get }
}

@available(iOS 17.0, *)
@available(watchOS 9.0, *)
public class HomeEnergyStateManager {
    public static var shared: HomeEnergyStateManager = .init()

    public let modelContainer: ModelContainer
    let network: Networking
    let keychainStore = KeychainStore()

    init() {
        do {
            network = NetworkService.standard(keychainStore: keychainStore,
                                              isDemoUser: {
                                                  false
                                              },
                                              dataCeiling: { .none })
            modelContainer = try ModelContainer(for: BatteryWidgetState.self)
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
    public func update(config: HomeEnergyStateManagerConfig) async throws {
        guard await isStale() else { return }
        guard let deviceSN = config.selectedDeviceSN else { throw ConfigManager.NoDeviceFoundError() }

        let real = try await network.fetchRealData(
            deviceSN: deviceSN,
            variables: ["SoC",
                        "SoC_1",
                        "batChargePower",
                        "batDischargePower",
                        "batTemperature",
                        "ResidualEnergy"]
        )
        let calculator = BatteryCapacityCalculator(capacityW: config.batteryCapacityW,
                                                   minimumSOC: config.minSOC,
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
        let soc = calculator.effectiveBatteryStateOfCharge(batteryStateOfCharge: viewModel.chargeLevel, includeUnusableCapacity: !config.showUsableBatteryOnly)

        let chargeStatusDescription = calculator.batteryChargeStatusDescription(
            batteryChargePowerkW: viewModel.chargePower,
            batteryStateOfCharge: soc
        )

        try update(soc: Int(soc * 100.0), chargeStatusDescription: chargeStatusDescription, batteryPower: viewModel.chargePower)
    }

    @MainActor
    private func update(soc: Int, chargeStatusDescription: String?, batteryPower: Double) throws {
        let state = BatteryWidgetState(batterySOC: soc, chargeStatusDescription: chargeStatusDescription, batteryPower: batteryPower)

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