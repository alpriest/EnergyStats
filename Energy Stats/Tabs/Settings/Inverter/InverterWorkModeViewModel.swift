//
//  InverterWorkModeViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/12/2023.
//

import Energy_Stats_Core
import Foundation

struct InverterWorkModeViewData: Copiable {
    var items: [SelectableItem]
    
    func create(copying previous: InverterWorkModeViewData) -> InverterWorkModeViewData {
        .init(items: previous.items)
    }
}

class InverterWorkModeViewModel: ObservableObject, ViewDataProviding {
    typealias ViewData = InverterWorkModeViewData
    
    private let networking: Networking
    private var config: ConfigManaging
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?
    @Published var viewData: ViewData = ViewData(items: []) { didSet {
        isDirty = viewData != originalValue
    }}
    var originalValue: ViewData?
    @Published var isDirty = false

    init(networking: Networking, config: ConfigManaging) {
        self.networking = networking
        self.config = config

        load()
    }

    func load() {
        Task { @MainActor in
            guard !state.isActive else { return }
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            state = .active(.loading)

            do {
                let response = try await networking.fetchDeviceSettingsItem(deviceSN: deviceSN, item: .workMode)
                let workMode = response.value
                if config.workModes.count == 0 {
                    config.workModes = try await fetchWorkmodes(deviceSN: deviceSN)
                }
                let viewData = ViewData(items: config.workModes.map { SelectableItem($0, isSelected: $0 == workMode) })
                self.originalValue = viewData
                self.viewData = viewData

                state = .inactive
            } catch {
                state = .error(error, "Could not load work mode")
            }
        }
    }

    private func fetchWorkmodes(deviceSN: String) async throws -> [String] {
        let scheduleResponse = try await networking.fetchCurrentSchedule(deviceSN: deviceSN)
        return scheduleResponse.workmodes
    }

    func save() {
        guard let mode = selected else { return }

        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            state = .active(.saving)

            do {
                try await networking.setDeviceSettingsItem(deviceSN: deviceSN, item: .workMode, value: WorkMode.networkTitle(for: mode))
                resetDirtyState()
                alertContent = AlertContent(title: "Success", message: "inverter_settings_saved")
                state = .inactive
            } catch let NetworkError.foxServerError(code, _) where code == 44096 {
                alertContent = AlertContent(title: "Failed", message: "cannot_save_due_to_active_schedule")
                state = .inactive
            } catch {
                state = .error(error, "Could not save work mode")
            }
        }
    }

    func toggle(updating: SelectableItem) {
        viewData = viewData.copy {
            $0.items = viewData.items.map { existingVariable in
                var existingVariable = existingVariable
                
                if existingVariable.id == updating.id {
                    existingVariable.setSelected(true)
                } else {
                    existingVariable.setSelected(false)
                }
                
                return existingVariable
            }
        }
    }

    var selected: WorkMode? {
        viewData.items.first(where: { $0.isSelected })?.item
    }
}
