//
//  SettingsTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/03/2023.
//

import SwiftUI
import Energy_Stats_Core

class SettingsTabViewModel: ObservableObject {
    @Published var showColouredLines: Bool {
        didSet {
            config.showColouredLines = showColouredLines
        }
    }

    @Published var batteryCapacity: String {
        didSet {
            config.batteryCapacity = batteryCapacity
        }
    }

    @Published var showBatteryTemperature: Bool {
        didSet {
            config.showBatteryTemperature = showBatteryTemperature
        }
    }

    @Published var showBatteryEstimate: Bool {
        didSet {
            config.showBatteryEstimate = showBatteryEstimate
        }
    }

    @Published var refreshFrequency: RefreshFrequency {
        didSet {
            config.refreshFrequency = refreshFrequency
        }
    }

    @Published var decimalPlaces: Int = 2 {
        didSet {
            config.decimalPlaces = decimalPlaces
        }
    }

    @Published var showSunnyBackground: Bool {
        didSet {
            config.showSunnyBackground = showSunnyBackground
        }
    }

    @Published var selectedDeviceID: String {
        didSet {
            config.selectedDeviceID = selectedDeviceID
        }
    }

    private var config: ConfigManaging
    private let userManager: UserManager

    init(userManager: UserManager, config: ConfigManaging) {
        self.userManager = userManager
        self.config = config
        showColouredLines = config.showColouredLines
        batteryCapacity = String(describing: config.batteryCapacity)
        showBatteryTemperature = config.showBatteryTemperature
        refreshFrequency = config.refreshFrequency
        decimalPlaces = config.decimalPlaces
        showSunnyBackground = config.showSunnyBackground
        selectedDeviceID = config.selectedDeviceID ?? ""
        showBatteryEstimate = config.showBatteryEstimate
    }

    var minSOC: Double { config.minSOC }
    var username: String { userManager.getUsername() ?? "" }
    var devices: [Device] { config.devices ?? [] }

    @MainActor
    func logout() {
        userManager.logout()
    }
}
