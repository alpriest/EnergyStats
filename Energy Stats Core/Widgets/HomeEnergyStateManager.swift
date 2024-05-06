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

        try update(
            openQueryResponse: real,
            batteryCapacityW: config.batteryCapacityW,
            minSOC: config.minSOC,
            showUsableBatteryOnly: config.showUsableBatteryOnly
        )
    }

    @MainActor
    public func update(
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

        try update(soc: Int(soc * 100.0), chargeStatusDescription: chargeStatusDescription, batteryPower: batteryViewModel.chargePower)
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

public extension OpenQueryResponse {
    func makeBatteryViewModel() -> BatteryViewModel {
        let chargePower = datas.currentDouble(for: "batChargePower")
        let dischargePower = datas.currentDouble(for: "batDischargePower")
        let power = chargePower > 0 ? chargePower : -dischargePower

        return BatteryViewModel(
            power: power,
            soc: Int(datas.SoC()),
            residual: datas.currentDouble(for: "ResidualEnergy") * 10.0,
            temperature: datas.currentDouble(for: "batTemperature")
        )
    }
}
