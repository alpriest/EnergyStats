//
//  ConfigManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/04/2023.
//

import Combine
import Foundation

public class ConfigManager: ConfigManaging {
    private let networking: FoxESSNetworking
    private var config: Config
    public var appSettingsPublisher: CurrentValueSubject<AppSettings, Never>
    public var currentDevice = CurrentValueSubject<Device?, Never>(nil)

    public struct NoDeviceFoundError: Error {
        public init() {}
    }

    public struct NoBattery: Error {
        public init() {}
    }

    public init(networking: FoxESSNetworking, config: Config, appSettingsPublisher: CurrentValueSubject<AppSettings, Never>) {
        self.networking = networking
        self.config = config
        self.appSettingsPublisher = appSettingsPublisher
        selectedDeviceSN = selectedDeviceSN
    }

    public func fetchDevices() async throws {
        let deviceList = try await networking.openapi_fetchDeviceList()
        config.variables = try await networking.openapi_fetchVariables().compactMap {
            guard let unit = $0.unit else { return nil }
            return Variable(name: $0.name, variable: $0.name, unit: unit)
        }

        guard deviceList.count > 0 else {
            throw NoDeviceFoundError()
        }

        let newDevices = await deviceList.asyncMap { device in
            let deviceBattery: Device.Battery?

            if device.hasBattery {
                do {
                    // TODO
//                    let battery = try await networking.fetchBattery(deviceID: device.deviceID)
//                    let batterySettings = try await networking.fetchBatterySettings(deviceSN: device.deviceSN)

//                    deviceBattery = BatteryResponseMapper.map(battery: battery, settings: batterySettings)
                    deviceBattery = nil
                } catch {
                    deviceBattery = nil
                }
            } else {
                deviceBattery = nil
            }

            return Device(
                deviceSN: device.deviceSN,
                stationName: device.stationName,
                stationID: device.stationID,
                battery: deviceBattery,
                firmware: DeviceFirmwareVersion(master: device.masterVersion, slave: device.slaveVersion, manager: device.managerVersion),
                moduleSN: device.moduleSN,
                deviceType: device.deviceType,
                hasPV: device.hasPV,
                hasBattery: device.hasBattery
            )
        }
        devices = newDevices
        if selectedDeviceSN == nil {
            select(device: devices?.first)
        } else if currentDevice.value == nil {
            select(device: devices?.first(where: { $0.deviceSN == selectedDeviceSN }))
        }
    }

    public func logout() {
        config.clear()
    }

    public func select(device: Device?) {
        guard let device else { return }

        selectedDeviceSN = device.deviceSN
    }

    public var firmwareVersions: DeviceFirmwareVersion? {
        currentDevice.value?.firmware
    }

    public var minSOC: Double { Double(currentDevice.value?.battery?.minSOC ?? "0.2") ?? 0.0 }

    public var variables: [Variable] {
        config.variables
    }

    public var batteryCapacity: String {
        get {
            if let currentDevice = currentDevice.value {
                let override = config.deviceBatteryOverrides[currentDevice.deviceSN]

                return override ?? "0"
            } else {
                return "0"
            }
        }
        set {
            if let currentDevice = currentDevice.value {
                config.deviceBatteryOverrides[currentDevice.deviceSN] = newValue
            }

            devices = devices?.map {
                $0
            }
        }
    }

    public var hasRunBefore: Bool {
        get { config.hasRunBefore }
        set { config.hasRunBefore = newValue }
    }

    public func clearBatteryOverride(for deviceID: String) {
        config.deviceBatteryOverrides.removeValue(forKey: deviceID)
    }

    public var hasBattery: Bool {
        true // TODO: Move to config but hanging off currentDevice
//        currentDevice.value?.hasBattery ?? false
    }

    public var batteryCapacityW: Int {
        Int(batteryCapacity) ?? 0
    }

    public var selectedDeviceSN: String? {
        get { config.selectedDeviceSN }
        set {
            config.selectedDeviceSN = newValue
            currentDevice.send(devices?.first(where: { $0.deviceSN == selectedDeviceSN }) ?? devices?.first)
        }
    }

    public var currencySymbol: String {
        get { config.currencySymbol }
        set {
            config.currencySymbol = newValue
        }
    }

    public var isDemoUser: Bool {
        get { config.isDemoUser }
        set {
            config.isDemoUser = newValue
        }
    }

    public var showColouredLines: Bool {
        get { config.showColouredLines }
        set {
            config.showColouredLines = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showColouredLines: config.showColouredLines
            ))
        }
    }

    public var showBatteryTemperature: Bool {
        get { config.showBatteryTemperature }
        set {
            config.showBatteryTemperature = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showBatteryTemperature: config.showBatteryTemperature
            ))
        }
    }

    public var showBatteryEstimate: Bool {
        get { config.showBatteryEstimate }
        set {
            config.showBatteryEstimate = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showBatteryEstimate: config.showBatteryEstimate
            ))
        }
    }

    public var showUsableBatteryOnly: Bool {
        get { config.showUsableBatteryOnly }
        set {
            config.showUsableBatteryOnly = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showUsableBatteryOnly: config.showUsableBatteryOnly
            ))
        }
    }

    public var refreshFrequency: RefreshFrequency {
        get { RefreshFrequency(rawValue: config.refreshFrequency) ?? .AUTO }
        set { config.refreshFrequency = newValue.rawValue }
    }

    public var showSunnyBackground: Bool {
        get { config.showSunnyBackground }
        set {
            config.showSunnyBackground = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showSunnyBackground: config.showSunnyBackground
            ))
        }
    }

    public var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode {
        get { config.selfSufficiencyEstimateMode }
        set {
            config.selfSufficiencyEstimateMode = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                selfSufficiencyEstimateMode: config.selfSufficiencyEstimateMode
            ))
        }
    }

    public var decimalPlaces: Int {
        get { config.decimalPlaces }
        set {
            config.decimalPlaces = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                decimalPlaces: config.decimalPlaces
            ))
        }
    }

    public var displayUnit: DisplayUnit {
        get { DisplayUnit(rawValue: config.displayUnit) ?? .kilowatt }
        set {
            config.displayUnit = newValue.rawValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                displayUnit: newValue
            ))
        }
    }

    public var showFinancialEarnings: Bool {
        get { config.showFinancialEarnings }
        set {
            config.showFinancialEarnings = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showFinancialEarnings: config.showFinancialEarnings
            ))
        }
    }

    public var showFinancialSummaryOnFlowPage: Bool {
        get { config.showFinancialSummaryOnFlowPage }
        set {
            config.showFinancialSummaryOnFlowPage = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showFinancialSummaryOnFlowPage: config.showFinancialSummaryOnFlowPage
            ))
        }
    }

    public var feedInUnitPrice: Double {
        get { config.feedInUnitPrice }
        set {
            config.feedInUnitPrice = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                feedInUnitPrice: config.feedInUnitPrice
            ))
        }
    }

    public var gridImportUnitPrice: Double {
        get { config.gridImportUnitPrice }
        set {
            config.gridImportUnitPrice = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                feedInUnitPrice: config.gridImportUnitPrice
            ))
        }
    }

    public var showInverterTemperature: Bool {
        get { config.showInverterTemperature }
        set {
            config.showInverterTemperature = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showInverterTemperature: config.showInverterTemperature
            ))
        }
    }

    public var solarDefinitions: SolarRangeDefinitions {
        get { config.solarDefinitions }
        set {
            config.solarDefinitions = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                solarDefinitions: config.solarDefinitions
            ))
        }
    }

    public var parameterGroups: [ParameterGroup] {
        get { config.parameterGroups }
        set {
            config.parameterGroups = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                parameterGroups: config.parameterGroups
            ))
        }
    }

    public var showGraphValueDescriptions: Bool {
        get { config.showGraphValueDescriptions }
        set {
            config.showGraphValueDescriptions = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showGraphValueDescriptions: config.showGraphValueDescriptions
            ))
        }
    }

    public var devices: [Device]? {
        get {
            guard let deviceListData = config.devices else { return nil }
            do {
                return try JSONDecoder().decode([Device].self, from: deviceListData)
            } catch {
                return nil
            }
        }
        set {
            if let newValue {
                do {
                    config.devices = try JSONEncoder().encode(newValue)
                } catch {
                    print("AWP", "Failed to encode device list 💥")
                }
            } else {
                config.devices = nil
            }
        }
    }

    public var selectedParameterGraphVariables: [String] {
        get { config.selectedParameterGraphVariables }
        set {
            config.selectedParameterGraphVariables = newValue
        }
    }

    public var showHomeTotalOnPowerFlow: Bool {
        get { config.showHomeTotalOnPowerFlow }
        set {
            config.showHomeTotalOnPowerFlow = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showHomeTotalOnPowerFlow: config.showHomeTotalOnPowerFlow
            ))
        }
    }

    public var showInverterIcon: Bool {
        get { config.showInverterIcon }
        set {
            config.showInverterIcon = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showInverterIcon: config.showInverterIcon
            ))
        }
    }

    public var shouldInvertCT2: Bool {
        get { config.shouldInvertCT2 }
        set {
            config.shouldInvertCT2 = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                shouldInvertCT2: config.shouldInvertCT2
            ))
        }
    }

    public var showInverterStationName: Bool {
        get { config.showInverterStationName }
        set {
            config.showInverterStationName = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showInverterStationName: config.showInverterStationName
            ))
        }
    }

    public var showGridTotalsOnPowerFlow: Bool {
        get { config.showGridTotalsOnPowerFlow }
        set {
            config.showGridTotalsOnPowerFlow = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showGridTotalsOnPowerFlow: config.showGridTotalsOnPowerFlow
            ))
        }
    }

    public var showLastUpdateTimestamp: Bool {
        get { config.showLastUpdateTimestamp }
        set {
            config.showLastUpdateTimestamp = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showLastUpdateTimestamp: config.showLastUpdateTimestamp
            ))
        }
    }

    public var shouldCombineCT2WithPVPower: Bool {
        get { config.shouldCombineCT2WithPVPower }
        set {
            config.shouldCombineCT2WithPVPower = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                shouldCombineCT2WithPVPower: config.shouldCombineCT2WithPVPower
            ))
        }
    }

    public var solcastSettings: SolcastSettings {
        get { config.solcastSettings }
        set {
            config.solcastSettings = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                solcastSettings: config.solcastSettings
            ))
        }
    }

    public var dataCeiling: DataCeiling {
        get { config.dataCeiling }
        set {
            config.dataCeiling = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                dataCeiling: config.dataCeiling
            ))
        }
    }

    public var showTotalYieldOnPowerFlow: Bool {
        get { config.showTotalYieldOnPowerFlow }
        set {
            config.showTotalYieldOnPowerFlow = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                showTotalYieldOnPowerFlow: showTotalYieldOnPowerFlow
            ))
        }
    }

    public var separateParameterGraphsByUnit: Bool {
        get { config.separateParameterGraphsByUnit }
        set {
            config.separateParameterGraphsByUnit = newValue
            appSettingsPublisher.send(appSettingsPublisher.value.copy(
                separateParameterGraphsByUnit: config.separateParameterGraphsByUnit
            ))
        }
    }
}

public enum BatteryResponseMapper {
    public static func map(battery: BatteryResponse, settings: BatterySettingsResponse) -> Device.Battery {
        let batteryCapacity: String
        let minSOC: String

        if battery.soc > 0 {
            batteryCapacity = String(Int(battery.residual / (Double(battery.soc) / 100.0)))
        } else {
            batteryCapacity = "0"
        }
        minSOC = String(Double(settings.minSocOnGrid) / 100.0)

        return Device.Battery(capacity: batteryCapacity, minSOC: minSOC)
    }
}
