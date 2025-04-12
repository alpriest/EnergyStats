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
    @Published var alertContent: AlertContent?

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
                let response = try await networking.fetchDeviceSettingsItem(deviceSN: deviceSN, item: item)

                Task { @MainActor in
                    self.value = response.value
                    self.unit = response.unit ?? item.fallbackUnit
                }

                await setState(.inactive)
            } catch {
                alertContent = AlertContent(title: "error_title", message: "Could not load settings")
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
                alertContent = AlertContent(title: "Success", message: "inverter_settings_saved")
            } catch let NetworkError.foxServerError(code, _) where code == 44096 {
                alertContent = AlertContent(title: "Failed", message: "cannot_save_due_to_active_schedule")
                await setState(.inactive)
            } catch {
                await setState(.error(error, "Could not save setting"))
            }
        }
    }
}
