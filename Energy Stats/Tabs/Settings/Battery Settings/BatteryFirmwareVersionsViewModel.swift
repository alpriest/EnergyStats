//
//  BatteryFirmwareVersionsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 01/04/2025.
//

import Energy_Stats_Core
import SwiftUI

class BatteryFirmwareVersionsViewModel: ObservableObject, HasLoadState {
    @Published var state = LoadState.inactive
    @Published var modules: [DeviceBatteryModule] = []
    let network: Networking
    let config: ConfigManaging

    init(network: Networking, config: ConfigManaging) {
        self.network = network
        self.config = config
    }

    func load() async {
        guard let selectedDeviceSN = config.selectedDeviceSN else { return }
        guard modules.isEmpty || state.isError else { return }

        await setState(.active(.loading))

        Task {
            let device = try await network.fetchDevice(deviceSN: selectedDeviceSN)

            await MainActor.run {
                if let batteryList = device.batteryList {
                    modules = batteryList.map { DeviceBatteryModule(batterySN: $0.batterySN, type: $0.type, version: $0.version) }
                    Task { await setState(.inactive) }
                } else {
                    state = .error(nil, "Failed to fetch battery information")
                }
            }
        }
    }
}
