//
//  BatterySOCSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/07/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

struct BatterySOCSettingsViewData: Copiable, Equatable {
    var soc: String
    var socOnGrid: String
    var errorMessage: LocalizedStringKey?

    init(soc: String, socOnGrid: String, errorMessage: LocalizedStringKey? = nil) {
        self.soc = soc
        self.socOnGrid = socOnGrid
        self.errorMessage = errorMessage
    }

    func create(copying previous: BatterySOCSettingsViewData) -> BatterySOCSettingsViewData {
        BatterySOCSettingsViewData(soc: previous.soc, socOnGrid: previous.socOnGrid, errorMessage: previous.errorMessage)
    }
}

class BatterySOCSettingsViewModel: ObservableObject, HasLoadState {
    private let networking: Networking
    private let config: ConfigManaging
    private let onSOCchange: () -> Void
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?
    @Published var viewData: BatterySOCSettingsViewData = .init(soc: "", socOnGrid: "") { didSet {
        isDirty = viewData != originalValue
    }}
    @Published var isDirty = false
    private var originalValue: BatterySOCSettingsViewData?

    init(networking: Networking, config: ConfigManaging, onSOCchange: @escaping () -> Void) {
        self.networking = networking
        self.config = config
        self.onSOCchange = onSOCchange

        load()
    }

    func load() {
        Task { @MainActor in
            guard !state.isActive else { return }
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            await setState(.active(.loading))

            do {
                let settings = try await networking.fetchBatterySettings(deviceSN: deviceSN)
                let viewData = BatterySOCSettingsViewData(
                    soc: String(describing: settings.minSoc),
                    socOnGrid: String(describing: settings.minSocOnGrid)
                )
                self.originalValue = viewData
                self.viewData = viewData

                await setState(.inactive)
            } catch {
                await setState(.error(error, "Could not load settings"))
            }
        }
    }

    func save() {
        Task { @MainActor in
            guard let soc = Int(viewData.soc),
                  let socOnGrid = Int(viewData.socOnGrid),
                  let deviceSN = config.currentDevice.value?.deviceSN,
                  (1...100).contains(soc),
                  (1...100).contains(socOnGrid)
            else {
                viewData = viewData.copy {
                    $0.errorMessage = "Cannot save, please check the values are within the range 1 to 100"
                }
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
