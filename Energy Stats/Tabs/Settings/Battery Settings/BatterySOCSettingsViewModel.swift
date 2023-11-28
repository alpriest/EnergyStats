//
//  BatterySOCSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/07/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class BatterySOCSettingsViewModel: ObservableObject {
    private let networking: FoxESSNetworking
    private let config: ConfigManaging
    private let onSOCchange: () -> Void
    @Published var soc: String = ""
    @Published var socOnGrid: String = ""
    @Published var errorMessage: LocalizedStringKey?
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?

    init(networking: FoxESSNetworking, config: ConfigManaging, onSOCchange: @escaping () -> Void) {
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
            guard let soc = Int(soc),
                  let socOnGrid = Int(socOnGrid),
                  let deviceSN = config.currentDevice.value?.deviceSN,
                  (1...100).contains(soc),
                  (1...100).contains(socOnGrid)
            else {
                errorMessage = "Cannot save, please check the values are within the range 1 to 100"
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

                alertContent = AlertContent(title: "Success", message: "batterySOC_settings_saved")
                state = .inactive
            } catch {
                state = .error(error, "Could not save settings")
            }
        }
    }
}
