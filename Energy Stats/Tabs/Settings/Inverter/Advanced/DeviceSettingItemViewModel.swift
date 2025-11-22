//
//  DeviceSettingItemViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/04/2025.
//

import Energy_Stats_Core
import SwiftUI

struct DeviceSettingItemViewData: Copiable {
    var value: String
    var unit: String
    var title: String
    var description: String
    var behaviour: String

    init(value: String, unit: String, title: String, description: String, behaviour: String) {
        self.value = value
        self.unit = unit
        self.title = title
        self.description = description
        self.behaviour = behaviour
    }

    func create(copying previous: DeviceSettingItemViewData) -> DeviceSettingItemViewData {
        DeviceSettingItemViewData(
            value: previous.value,
            unit: previous.unit,
            title: previous.title,
            description: previous.description,
            behaviour: previous.behaviour
        )
    }
}

class DeviceSettingItemViewModel: ObservableObject, HasLoadState, ViewDataProviding {
    typealias ViewData = DeviceSettingItemViewData
    
    private let item: DeviceSettingsItem
    private let networking: Networking
    private let configManager: ConfigManaging
    var title: String { item.title }
    var description: String { item.description }
    var behaviour: String { item.behaviour }
    @Published var state = LoadState.inactive
    @Published var alertContent: AlertContent?
    @Published var viewData: ViewData = .init(
        value: "",
        unit: "",
        title: "",
        description: "",
        behaviour: ""
    ) { didSet {
        isDirty = viewData != originalValue
    }}
    @Published var isDirty = false
    var originalValue: ViewData?

    init(item: DeviceSettingsItem, networking: Networking, configManager: ConfigManaging) {
        self.item = item
        self.configManager = configManager
        self.networking = networking
        
        self.viewData = viewData.copy {
            $0.title = item.title
            $0.description = item.description
            $0.behaviour = item.behaviour
        }

        load()
    }

    func load() {
        guard !state.isActive else { return }
        guard let deviceSN = configManager.currentDevice.value?.deviceSN else { return }

        Task {
            await setState(.active(.loading))

            do {
                let response = try await networking.fetchDeviceSettingsItem(deviceSN: deviceSN, item: item)

                let viewData = ViewData(
                    value: response.value,
                    unit: response.unit ?? item.fallbackUnit,
                    title: item.title,
                    description: item.description,
                    behaviour: item.behaviour
                )
                originalValue = viewData
                Task { @MainActor in
                    self.viewData = viewData
                }

                await setState(.inactive)
            } catch {
                await setState(.error(error, "Could not load settings"))
            }
        }
    }

    func save() {
        guard state == .inactive else { return }
        guard let deviceSN = configManager.currentDevice.value?.deviceSN else { return }

        Task {
            await setState(.active(.saving))

            do {
                try await networking.setDeviceSettingsItem(deviceSN: deviceSN, item: item, value: viewData.value)
                resetDirtyState()
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
