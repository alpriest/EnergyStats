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
    @Published var showGraphValueDescriptions: Bool {
        didSet {
            config.showGraphValueDescriptions = showGraphValueDescriptions
        }
    }

    @Published var showLastUpdateTimestamp: Bool {
        didSet {
            config.showLastUpdateTimestamp = showLastUpdateTimestamp
        }
    }

    @Published var showInverterTypeNameOnPowerFlow: Bool {
        didSet {
            config.showInverterTypeNameOnPowerFlow = showInverterTypeNameOnPowerFlow
        }
    }

    @Published var showInverterPlantName: Bool {
        didSet {
            config.showInverterPlantName = showInverterPlantName
        }
    }

    @Published var showColouredLines: Bool {
        didSet {
            config.showColouredLines = showColouredLines
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

    @Published var displayUnit: DisplayUnit {
        didSet {
            config.displayUnit = displayUnit
        }
    }

    @Published var dataCeiling: DataCeiling {
        didSet {
            config.dataCeiling = dataCeiling
        }
    }

    @Published var showInverterTemperature: Bool {
        didSet {
            config.showInverterTemperature = showInverterTemperature
        }
    }

    @Published var hasBattery: Bool
    @Published var firmwareVersions: DeviceFirmwareVersion?

    @Published var showHomeTotalOnPowerFlow: Bool {
        didSet {
            config.showHomeTotalOnPowerFlow = showHomeTotalOnPowerFlow
        }
    }

    @Published var showInverterIcon: Bool {
        didSet {
            config.showInverterIcon = showInverterIcon
        }
    }

    @Published var shouldInvertCT2: Bool {
        didSet {
            config.shouldInvertCT2 = shouldInvertCT2
        }
    }

    @Published var showGridTotalsOnPowerFlow: Bool {
        didSet {
            config.showGridTotalsOnPowerFlow = showGridTotalsOnPowerFlow
        }
    }

    @Published var shouldCombineCT2WithPVPower: Bool {
        didSet {
            config.shouldCombineCT2WithPVPower = shouldCombineCT2WithPVPower
        }
    }

    @Published var showHalfHourlyTimeSelectors: Bool {
        didSet {
            config.showHalfHourlyTimeSelectors = showHalfHourlyTimeSelectors
        }
    }

    private(set) var config: ConfigManaging
    private let userManager: UserManager
    private var cancellables = Set<AnyCancellable>()
    let networking: FoxESSNetworking

    init(userManager: UserManager, config: ConfigManaging, networking: FoxESSNetworking) {
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
        displayUnit = config.displayUnit
        batteryCapacity = String(describing: config.batteryCapacity)
        hasBattery = config.hasBattery
        firmwareVersions = config.firmwareVersions
        showTotalYield = config.showTotalYield
        showInverterTemperature = config.showInverterTemperature
        showHomeTotalOnPowerFlow = config.showHomeTotalOnPowerFlow
        showInverterIcon = config.showInverterIcon
        shouldInvertCT2 = config.shouldInvertCT2
        showInverterPlantName = config.showInverterPlantName
        showGridTotalsOnPowerFlow = config.showGridTotalsOnPowerFlow
        showInverterTypeNameOnPowerFlow = config.showInverterTypeNameOnPowerFlow
        showLastUpdateTimestamp = config.showLastUpdateTimestamp
        shouldCombineCT2WithPVPower = config.shouldCombineCT2WithPVPower
        showGraphValueDescriptions = config.showGraphValueDescriptions
        dataCeiling = config.dataCeiling
        showHalfHourlyTimeSelectors = config.showHalfHourlyTimeSelectors

        config.currentDevice.sink { [weak self] _ in
            guard let self else { return }

            Task { @MainActor in
                self.batteryCapacity = String(describing: config.batteryCapacity)
                self.hasBattery = config.hasBattery
                self.firmwareVersions = config.firmwareVersions
            }
        }.store(in: &cancellables)
    }

    var username: String { userManager.getUsername() ?? "" }
    @Published var showAlert = false
    @Published var showRecalculationAlert = false

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

        Task { @MainActor [networking] in
            let battery = try await networking.fetchBattery(deviceID: device.deviceID)
            let batterySettings = try await networking.fetchBatterySettings(deviceSN: device.deviceSN)

            if battery.soc > 0 {
                let battery = BatteryResponseMapper.map(battery: battery, settings: batterySettings)

                config.devices = devices.map {
                    if $0.deviceID == device.deviceID {
                        return $0.copy(battery: battery)
                    } else {
                        return $0
                    }
                }
                config.select(device: device)
                config.clearBatteryOverride(for: device.deviceID)
                batteryCapacity = config.batteryCapacity
                showRecalculationAlert = true
            }
        }
    }
}
