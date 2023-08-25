//
//  BatterySOCSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/07/2023.
//

import Foundation
import Energy_Stats_Core

class BatterySOCSettingsViewModel: ObservableObject {
    private let networking: Networking
    private let config: ConfigManaging
    private let onSOCchange: () -> Void
    @Published var soc: String = ""
    @Published var socOnGrid: String = ""
    @Published var errorMessage: String?
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?

    init(networking: Networking, config: ConfigManaging, onSOCchange: @escaping () -> Void) {
        self.networking = networking
        self.config = config
        self.onSOCchange = onSOCchange

        load()
    }

    func load() {
        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            state = .active(String(key: .loading))

            do {
                let settings = try await networking.fetchBatterySettings(deviceSN: deviceSN)
                self.soc = String(describing: settings.minSoc)
                self.socOnGrid = String(describing: settings.minGridSoc)

                state = .inactive
            } catch {
                state = .error(error, "Could not load settings")
            }
        }
    }

    func save() {
        Task { @MainActor in
            guard let soc = Int(soc), let socOnGrid = Int(socOnGrid), let deviceSN = config.currentDevice.value?.deviceSN else {
                errorMessage = "Cannot save, please check values"
                return
            }
            state = .active(String(key: .saving))

            do {
                try await networking.setSoc(
                    minGridSOC: socOnGrid,
                    minSOC: soc,
                    deviceSN: deviceSN
                )

                onSOCchange()

                alertContent = AlertContent(title: "Success", message: String(key: .batterySOCSettingsWereSaved))
                state = .inactive
            } catch {
                state = .error(error, "Could not save settings")
            }
        }
    }
}
