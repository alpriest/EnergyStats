//
//  Untitled.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/07/2025.
//

import AppIntents
import SwiftData
import WidgetKit

@available(iOS 17.0, *)
@available(watchOS 9.0, *)
public extension HomeEnergyStateManager {
    @MainActor
    func isBatteryStateStale() async -> Bool {
        let fetchDescriptor: FetchDescriptor<BatteryWidgetState> = FetchDescriptor()
        guard let widgetState = (try? modelContainer.mainContext.fetch(fetchDescriptor))?.first else { return true }

        return widgetState.lastUpdated.timeIntervalSinceNow < -60
    }

    @MainActor
    func updateBatteryState(config: HomeEnergyStateManagerConfig) async throws {
        guard await isBatteryStateStale() else { return }
        guard let deviceSN = try config.selectedDeviceSN() else { throw ConfigManager.NoDeviceFoundError() }

        let real = try await network.fetchRealData(
            deviceSN: deviceSN,
            variables: ["SoC",
                        "SoC_1",
                        "batChargePower",
                        "batDischargePower",
                        "batTemperature",
                        "batTemperature_1",
                        "batTemperature_2",
                        "ResidualEnergy"]
        )

        try calculateBatteryState(
            openQueryResponse: real,
            batteryCapacityW: config.batteryCapacityW(),
            minSOC: config.minSOC(),
            showUsableBatteryOnly: config.showUsableBatteryOnly()
        )
    }

    @MainActor
    func calculateBatteryState(
        openQueryResponse: OpenQueryResponse,
        batteryCapacityW: Int,
        minSOC: Double,
        showUsableBatteryOnly: Bool
    ) throws {
        let batteryViewModel = openQueryResponse.makeBatteryViewModel()
        let calculator = BatteryCapacityCalculator(capacityW: batteryCapacityW,
                                                   minimumSOC: minSOC,
                                                   bundle: Bundle(for: BundleLocator.self))
        let soc = calculator.effectiveBatteryStateOfCharge(batteryStateOfCharge: batteryViewModel.chargeLevel, includeUnusableCapacity: !showUsableBatteryOnly)

        let chargeStatusDescription = calculator.batteryChargeStatusDescription(
            batteryChargePowerkW: batteryViewModel.chargePower,
            batteryStateOfCharge: soc
        )

        try storeBatteryModel(soc: Int(soc * 100.0), chargeStatusDescription: chargeStatusDescription, batteryPower: batteryViewModel.chargePower)
    }

    @MainActor
    private func storeBatteryModel(soc: Int, chargeStatusDescription: String?, batteryPower: Double) throws {
        let state = BatteryWidgetState(
            batterySOC: soc,
            chargeStatusDescription: chargeStatusDescription,
            batteryPower: batteryPower
        )

        deleteOldBatteryStateEntries()

        modelContainer.mainContext.insert(state)
        modelContainer.mainContext.processPendingChanges()
    }

    @MainActor
    private func deleteOldBatteryStateEntries() {
        let fetchDescriptor: FetchDescriptor<BatteryWidgetState> = FetchDescriptor()
        do {
            for entry in try modelContainer.mainContext.fetch(fetchDescriptor) {
                modelContainer.mainContext.delete(entry)
            }
            try modelContainer.mainContext.save()
        } catch {
            print("AWP", "Could not delete entry")
        }
    }
}
