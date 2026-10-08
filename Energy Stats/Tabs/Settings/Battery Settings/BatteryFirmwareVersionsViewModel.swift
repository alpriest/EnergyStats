//
//  BatteryFirmwareVersionsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 01/04/2025.
//

import Energy_Stats_Core
import SwiftUI

@Observable
class BatteryFirmwareVersionsViewModel: HasLoadState {
    var state = LoadState.inactive
    var modules: [DeviceBatteryModule] = []
    private let network: Networking
    private let config: ConfigManaging

    init(network: Networking, config: ConfigManaging) {
        self.network = network
        self.config = config
    }

    func load() async {
        guard let selectedDeviceSN = config.selectedDeviceSN else { return }
        guard modules.isEmpty || state.isError else { return }

        await setState(.active(.loading))

        TaskIgnoringErrors { [weak self] in
            guard let self else { return }

            let device = try await network.fetchDevice(deviceSN: selectedDeviceSN)

            await MainActor.run {
                if let batteryList = device.batteryList {
                    self.modules = batteryList.map { DeviceBatteryModule(batterySN: $0.batterySN, type: $0.type, version: $0.version) }
                    Task { await self.setState(.inactive) }
                } else {
                    self.state = .error(nil, "Failed to fetch battery information")
                }
            }
        }
    }
}
