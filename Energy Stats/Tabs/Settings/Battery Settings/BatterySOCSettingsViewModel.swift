//
//  BatterySOCSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/07/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class BatterySOCSettingsViewModel: ObservableObject, HasLoadState {
    private let networking: Networking
    private let config: ConfigManaging
    private let onSOCchange: () -> Void
    @Published var soc: String = ""
    @Published var socOnGrid: String = ""
    @Published var errorMessage: LocalizedStringKey?
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
            await setState(.active(.loading))

            do {
                let settings = try await networking.fetchBatterySettings(deviceSN: deviceSN)
                self.soc = String(describing: settings.minSoc)
                self.socOnGrid = String(describing: settings.minSocOnGrid)

                await setState(.inactive)
            } catch {
                await setState(.error(error, "Could not load settings"))
            }
        }
    }

    func save() {
        Task { @MainActor in
            guard let soc = Int(soc),
                  let socOnGrid = Int(socOnGrid),
                  let deviceSN = config.currentDevice.value?.deviceSN,
                  (1...100).contains(soc),
                  (1...100).contains(socOnGrid)
            else {
                errorMessage = "Cannot save, please check the values are within the range 1 to 100"
                return
            }

            await setState(.active(.saving))

            do {
                try await networking.setBatterySoc(
                    deviceSN: deviceSN,
                    minSOCOnGrid: socOnGrid,
                    minSOC: soc
                )

                onSOCchange()

                alertContent = AlertContent(title: "Success", message: "batterySOC_settings_saved")
                await setState(.inactive)
            } catch let NetworkError.foxServerError(code, _) where code == 44096 {
                alertContent = AlertContent(title: "Failed", message: "cannot_save_due_to_active_schedule")
                await setState(.inactive)
            } catch {
                await setState(.error(error, "Could not save settings"))
            }
        }
    }
}
