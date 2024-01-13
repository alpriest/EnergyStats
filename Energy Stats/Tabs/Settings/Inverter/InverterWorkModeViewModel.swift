//
//  InverterWorkModeViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/12/2023.
//

import Energy_Stats_Core
import Foundation

class InverterWorkModeViewModel: ObservableObject {
    private let networking: FoxESSNetworking
    private let config: ConfigManaging
    @Published var state: LoadState = .inactive
    @Published var items: [SelectableItem<WorkMode>] = []
    @Published var alertContent: AlertContent?

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        self.networking = networking
        self.config = config

        load()
    }

    func load() {
        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            state = .active("Loading")

            // TODO
//            do {
//                let response = try await networking.fetchWorkMode(deviceSN: deviceSN)
//                let workMode = response.values.operationModeWorkMode.asWorkMode()
//                self.items = WorkMode.allCases.map { SelectableItem($0, isSelected: $0 == workMode) }
//
//                state = .inactive
//            } catch {
//                state = .error(error, "Could not load work mode")
//            }
        }
    }

    func save() {
        guard let mode = selected else { return }

        // TODO
//        Task { @MainActor in
//            guard state == .inactive else { return }
//            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
//            state = .active("Saving")
//
//            do {
//                try await networking.setWorkMode(deviceSN: deviceSN, workMode: mode.asInverterWorkMode())
//                alertContent = AlertContent(title: "Success", message: "inverter_settings_saved")
//                state = .inactive
//            } catch let NetworkError.foxServerError(code, _) where code == 44096 {
//                alertContent = AlertContent(title: "Failed", message: "cannot_save_due_to_active_schedule")
//                state = .inactive
//            } catch {
//                state = .error(error, "Could not save work mode")
//            }
//        }
    }

    func toggle(updating: SelectableItem<WorkMode>) {
        items = items.map { existingVariable in
            var existingVariable = existingVariable

            if existingVariable.id == updating.id {
                existingVariable.setSelected(true)
            } else {
                existingVariable.setSelected(false)
            }

            return existingVariable
        }
    }

    var selected: WorkMode? {
        items.first(where: { $0.isSelected })?.item
    }
}
