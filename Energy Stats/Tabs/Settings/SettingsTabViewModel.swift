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

    @Published var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode {
        didSet {
            config.selfSufficiencyEstimateMode = selfSufficiencyEstimateMode
        }
    }

    @Published var showTotalYield: Bool {
        didSet {
            config.showTotalYield = showTotalYield
        }
    }

    @Published var batteryCapacity: String

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
    @Published var selfSufficiencyEstimateRawMode = 0 {
        didSet {
            config.selfSufficiencyEstimateMode = SelfSufficiencyEstimateMode(rawValue: selfSufficiencyEstimateRawMode) ?? .off
        }
    }

    private var config: ConfigManaging
    private let userManager: UserManager
    private var cancellables = Set<AnyCancellable>()
    private let networking: Networking

    init(userManager: UserManager, config: ConfigManaging, networking: Networking) {
        self.userManager = userManager
        self.config = config
        self.networking = networking
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
        showTotalYield = config.showTotalYield
        selfSufficiencyEstimateMode = config.selfSufficiencyEstimateMode

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
    @Published var showAlert = false

    @MainActor
    func logout() {
        userManager.logout()
    }

    func saveBatteryCapacity() {
        if let int = Int(batteryCapacity), int > 0 {
            config.batteryCapacity = batteryCapacity
        } else {
            batteryCapacity = config.batteryCapacity
            showAlert = true
        }
    }

    func revertBatteryCapacityEdits() {
        batteryCapacity = config.batteryCapacity
    }

    var appVersion: String {
        let dictionary = Bundle.main.infoDictionary!
        return dictionary["CFBundleShortVersionString"] as! String
    }

    func recalculateBatteryCapacity() {
        guard let device = config.currentDevice.value else { return }
        guard let devices = config.devices else { return }

        Task { [networking] in
            let battery = try await networking.fetchBattery(deviceID: device.deviceID)
            let batterySettings = try await networking.fetchBatterySettings(deviceSN: device.deviceSN)

            if battery.soc > 0 {
                let battery = BatteryResponseMapper.map(battery: battery, settings: batterySettings)

                config.devices = devices.map {
                    if $0.deviceID == device.deviceID {
                        return Device(
                            plantName: $0.plantName,
                            deviceID: $0.deviceID,
                            deviceSN: $0.deviceSN,
                            hasPV: $0.hasPV,
                            battery: battery,
                            deviceType: $0.deviceType,
                            firmware: $0.firmware,
                            variables: $0.variables
                        )
                    } else {
                        return $0
                    }
                }
                config.select(device: device)
            }
        }
    }
}
