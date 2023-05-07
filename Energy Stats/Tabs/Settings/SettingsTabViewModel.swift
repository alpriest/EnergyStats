//
//  SettingsTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/03/2023.
//

import Combine
import Energy_Stats_Core
import SwiftUI

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

    @Published var showUsableBatteryOnly: Bool {
        didSet {
            config.showUsableBatteryOnly = showUsableBatteryOnly
        }
    }

    @Published var showInW: Bool {
        didSet {
            config.showInW = showInW
        }
    }

    @Published var hasBattery: Bool
    @Published var firmwareVersions: DeviceFirmwareVersion?

    private var config: ConfigManaging
    private let userManager: UserManager
    private var cancellables = Set<AnyCancellable>()

    init(userManager: UserManager, config: ConfigManaging) {
        self.userManager = userManager
        self.config = config
        showColouredLines = config.showColouredLines
        showBatteryTemperature = config.showBatteryTemperature
        refreshFrequency = config.refreshFrequency
        decimalPlaces = config.decimalPlaces
        showSunnyBackground = config.showSunnyBackground
        showBatteryEstimate = config.showBatteryEstimate
        showUsableBatteryOnly = config.showUsableBatteryOnly
        showInW = config.showInW
        minSOC = config.minSOC
        batteryCapacity = String(describing: config.batteryCapacity)
        hasBattery = config.hasBattery
        firmwareVersions = config.firmwareVersions

        config.currentDevice.sink { [weak self] _ in
            guard let self else { return }

            Task { @MainActor in
                self.minSOC = config.minSOC
                self.batteryCapacity = String(describing: config.batteryCapacity)
                self.hasBattery = config.hasBattery
                self.firmwareVersions = config.firmwareVersions
            }
        }.store(in: &cancellables)
    }

    @Published var minSOC: Double
    var username: String { userManager.getUsername() ?? "" }

    @MainActor
    func logout() {
        userManager.logout()
    }

    var appVersion: String {
        let dictionary = Bundle.main.infoDictionary!
        return dictionary["CFBundleShortVersionString"] as! String
    }
}
