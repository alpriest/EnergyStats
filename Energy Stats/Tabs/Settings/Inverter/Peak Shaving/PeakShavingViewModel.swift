//
//  PeakShavingViewModel.swift
//
//
//  Created by Alistair Priest on 22/11/2025.
//

import Energy_Stats_Core
import SwiftUI

struct PeakShavingViewData: Copiable {
    var importLimit: String
    var soc: String
    var supported: Bool
    
    func create(copying previous: PeakShavingViewData) -> PeakShavingViewData {
        .init(importLimit: previous.importLimit, soc: previous.soc, supported: previous.supported)
    }
}

class PeakShavingViewModel: ObservableObject, HasLoadState {
    typealias ViewData = PeakShavingViewData

    private let networking: Networking
    private let config: ConfigManaging
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?
    @Published var viewData: ViewData = ViewData(importLimit: "", soc: "", supported: false) { didSet {
        isDirty = originalValue != viewData
    }}
    @Published var isDirty = false
    private var originalValue: ViewData?

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

                let viewData = ViewData(
                    importLimit: settings.importLimit.value.removingEmptyDecimals(),
                    soc: settings.soc.value,
                    supported: true
                )
                self.originalValue = viewData
                self.viewData = viewData

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
            guard let importLimit = Double(viewData.importLimit), let soc = Int(viewData.soc) else { return }
            await setState(.active(.saving))

            do {
                try await networking.setPeakShavingSettings(
                    deviceSN: deviceSN,
                    importLimit: importLimit,
                    soc: soc
                )
                originalValue = viewData
                isDirty = false
                alertContent = AlertContent(title: "Success", message: "peak_shaving_settings_saved")
                await setState(.inactive)
            } catch {
                await setState(.error(error, "Could not save settings"))
            }
        }
    }
}
