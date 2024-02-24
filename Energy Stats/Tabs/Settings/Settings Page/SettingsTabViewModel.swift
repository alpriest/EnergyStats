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
    @Published var separateParameterGraphsByUnit: Bool {
        didSet {
            config.separateParameterGraphsByUnit = separateParameterGraphsByUnit
        }
    }

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

    @Published var showInverterStationName: Bool {
        didSet {
            config.showInverterStationName = showInverterStationName
        }
    }

    @Published var showInverterTypeName: Bool {
        didSet {
            config.showInverterTypeName = showInverterTypeName
        }
    }

    @Published var showColouredLines: Bool {
        didSet {
            config.showColouredLines = showColouredLines
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

    @Published var shouldCombineCT2WithLoadsPower: Bool {
        didSet {
            config.shouldCombineCT2WithLoadsPower = shouldCombineCT2WithLoadsPower
        }
    }

    @Published var showTotalYieldOnPowerFlow: Bool {
        didSet {
            config.showTotalYieldOnPowerFlow = showTotalYieldOnPowerFlow
        }
    }

    @Published var showSeparateStringsOnFlowPage: Bool {
        didSet {
            config.showSeparateStringsOnFlowPage = showSeparateStringsOnFlowPage
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
        showInverterTemperature = config.showInverterTemperature
        showHomeTotalOnPowerFlow = config.showHomeTotalOnPowerFlow
        showInverterIcon = config.showInverterIcon
        shouldInvertCT2 = config.shouldInvertCT2
        showInverterStationName = config.showInverterStationName
        showGridTotalsOnPowerFlow = config.showGridTotalsOnPowerFlow
        showLastUpdateTimestamp = config.showLastUpdateTimestamp
        shouldCombineCT2WithPVPower = config.shouldCombineCT2WithPVPower
        showGraphValueDescriptions = config.showGraphValueDescriptions
        dataCeiling = config.dataCeiling
        showTotalYieldOnPowerFlow = config.showTotalYieldOnPowerFlow
        separateParameterGraphsByUnit = config.separateParameterGraphsByUnit
        showInverterTypeName = config.showInverterTypeName
        shouldCombineCT2WithLoadsPower = config.shouldCombineCT2WithLoadsPower
        showSeparateStringsOnFlowPage = config.showSeparateStringsOnFlowPage

        config.currentDevice.sink { [weak self] _ in
            guard let self else { return }

            Task { @MainActor in
                self.batteryCapacity = String(describing: config.batteryCapacity)
                self.hasBattery = config.hasBattery
            }
        }.store(in: &cancellables)
    }

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
        guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
        guard let devices = config.devices else { return }

        Task { @MainActor [networking] in
            let real = try await networking.openapi_fetchRealData(deviceSN: deviceSN, variables: ["SoC", "ResidualEnergy"])
            let socResponse = try await networking.openapi_fetchBatterySettings(deviceSN: deviceSN)
            let batteryResponse = BatteryResponseMapper.map(batteryVariables: real, settings: socResponse)

            config.devices = devices.map {
                if $0.deviceSN == deviceSN {
                    return $0.copy(battery: batteryResponse)
                } else {
                    return $0
                }
            }
            config.select(device: config.devices?.first(where: { $0.deviceSN == deviceSN }))
            config.clearBatteryOverride(for: deviceSN)
            batteryCapacity = config.batteryCapacity
            showRecalculationAlert = true
        }
    }
}
