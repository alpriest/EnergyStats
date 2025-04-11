//
//  DeviceSettingItemViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/04/2025.
//

import Energy_Stats_Core
import SwiftUI

class DeviceSettingItemViewModel: ObservableObject, HasLoadState {
    private let item: DeviceSettingsItem
    private let networking: Networking
    private let configManager: ConfigManaging
    var title: String { item.title }
    var description: String { item.description }
    var behaviour: String { item.behaviour }
    @Published var value: String = ""
    @Published var unit: String = ""
    @Published var state = LoadState.inactive

    init(item: DeviceSettingsItem, networking: Networking, configManager: ConfigManaging) {
        self.item = item
        self.configManager = configManager
        self.networking = networking

        load()
    }

    func load() {
        guard state == .inactive else { return }
        guard let deviceSN = configManager.currentDevice.value?.deviceSN else { return }

        Task {
            await setState(.active(.loading))

            do {
                let item = try await networking.fetchDeviceSettingsItem(deviceSN: deviceSN, item: item)

                Task { @MainActor in
                    self.value = item.value
                    self.unit = item.unit
                }

                await setState(.inactive)
            } catch {
                state = .error(error, "Could not fetch setting")
            }
        }
    }

    func save() {
        guard state == .inactive else { return }
        guard let deviceSN = configManager.currentDevice.value?.deviceSN else { return }

        Task {
            await setState(.active(.saving))

            do {
                try await networking.setDeviceSettingsItem(deviceSN: deviceSN, item: item, value: value)
                await setState(.inactive)
            } catch {
                state = .error(error, "Could not save setting")
            }
        }
    }
}
