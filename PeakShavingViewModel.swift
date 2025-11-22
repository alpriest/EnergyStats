//
//  PeakShavingViewModel.swift
//
//
//  Created by Alistair Priest on 22/11/2025.
//

import Energy_Stats_Core
import SwiftUI

class PeakShavingViewModel: ObservableObject, HasLoadState {
    let networking: Networking
    let config: ConfigManaging
    @Published var state: LoadState = .inactive
    @Published var importLimit: String = ""
    @Published var soc: String = ""
    @Published var supported = false
    @Published var alertContent: AlertContent?

    init(networking: Networking, config: ConfigManaging) {
        self.networking = networking
        self.config = config

        load()
    }

    func load() {
        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            await setState(.active(.loading))

            do {
                let settings = try await networking.fetchPeakShavingSettings(deviceSN: deviceSN)

                self.importLimit = settings.importLimit.value.removingEmptyDecimals()
                self.soc = settings.soc.value
                self.supported = true

                await setState(.inactive)
            } catch {
                if case NetworkError.foxServerError(40257, "") = error {
                    await setState(.inactive)
                } else {
                    await setState(.error(error, "Could not load settings"))
                }
            }
        }
    }

    func save() {
        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            guard let importLimit = Double(importLimit), let soc = Int(soc) else { return }
            await setState(.active(.saving))

            do {
                try await networking.setPeakShavingSettings(
                    deviceSN: deviceSN,
                    importLimit: importLimit,
                    soc: soc
                )
                alertContent = AlertContent(title: "Success", message: "peak_shaving_settings_saved")
                await setState(.inactive)
            } catch {
                await setState(.error(error, "Could not save settings"))
            }
        }
    }
}
