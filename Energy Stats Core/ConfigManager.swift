//
//  ConfigManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/04/2023.
//

import Combine
import Foundation

public enum RefreshFrequency: Int {
    case AUTO = 0
    case ONE_MINUTE = 1
    case FIVE_MINUTES = 5
}

public protocol ConfigManaging {
    func fetchDevices() async throws
    func logout()
    func select(device: Device?)
    func refreshFirmwareVersions() async throws
    func clearBatteryOverride(for deviceID: String)
    var hasRunBefore: Bool { get set }
    var minSOC: Double { get }
    var batteryCapacity: String { get set }
    var batteryCapacityW: Int { get }
    var isDemoUser: Bool { get set }
    var showColouredLines: Bool { get set }
    var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode { get set }
    var showBatteryTemperature: Bool { get set }
    var showBatteryEstimate: Bool { get set }
    var showUsableBatteryOnly: Bool { get set }
    var showTotalYield: Bool { get set }
    var refreshFrequency: RefreshFrequency { get set }
    var appTheme: LatestAppTheme { get }
    var decimalPlaces: Int { get set }
    var showSunnyBackground: Bool { get set }
    var devices: [Device]? { get set }
    var selectedDeviceID: String? { get }
    var firmwareVersions: DeviceFirmwareVersion? { get }
    var showInW: Bool { get set }
    var variables: [RawVariable] { get }
    var currentDevice: CurrentValueSubject<Device?, Never> { get }
    var hasBattery: Bool { get }
    var showEarnings: Bool { get set }
    var showInverterTemperature: Bool { get set }
    var selectedParameterGraphVariables: [String] { get set }
    var showHomeTotalOnPowerFlow: Bool { get set }
    var showInverterIcon: Bool { get set }
    var shouldInvertCT2: Bool { get set }
    var showInverterPlantName: Bool { get set }
    var showGridTotalsOnPowerFlow: Bool { get set }
    var showInverterTypeNameOnPowerFlow: Bool { get set }
    var showLastUpdateTimestamp: Bool { get set }
    var solarDefinitions: SolarRangeDefinitions { get set }
    var parameterGroups: [ParameterGroup] { get set }
}

public class ConfigManager: ConfigManaging {
    private let networking: Networking
    private var config: Config
    public var appTheme: CurrentValueSubject<AppTheme, Never>
    public var currentDevice = CurrentValueSubject<Device?, Never>(nil)

    public struct NoDeviceFoundError: Error {
        public init() {}
    }

    public struct NoBattery: Error {
        public init() {}
    }

    public init(networking: Networking, config: Config) {
        self.networking = networking
        self.config = config
        appTheme = CurrentValueSubject(
            AppTheme(
                showColouredLines: config.showColouredLines,
                showBatteryTemperature: config.showBatteryTemperature,
                showSunnyBackground: config.showSunnyBackground,
                decimalPlaces: config.decimalPlaces,
                showBatteryEstimate: config.showBatteryEstimate,
                showUsableBatteryOnly: config.showUsableBatteryOnly,
                showInW: config.showInW,
                showTotalYield: config.showTotalYield,
                selfSufficiencyEstimateMode: config.selfSufficiencyEstimateMode,
                showEarnings: config.showEarnings,
                showInverterTemperature: config.showInverterTemperature,
                showHomeTotalOnPowerFlow: config.showHomeTotalOnPowerFlow,
                showInverterIcon: config.showInverterIcon,
                shouldInvertCT2: config.shouldInvertCT2,
                showInverterPlantName: config.showInverterPlantName,
                showGridTotalsOnPowerFlow: config.showGridTotalsOnPowerFlow,
                showInverterTypeNameOnPowerFlow: config.showInverterTypeNameOnPowerFlow,
                showLastUpdateTimestamp: config.showLastUpdateTimestamp,
                solarDefinitions: config.solarDefinitions,
                parameterGroups: config.parameterGroups
            )
        )
        selectedDeviceID = selectedDeviceID
    }

    public func fetchDevices() async throws {
        let deviceList = try await networking.fetchDeviceList()

        guard deviceList.count > 0 else {
            throw NoDeviceFoundError()
        }

        let newDevices = try await deviceList.asyncMap { device in
            let deviceBattery: Device.Battery?
            let firmware = try await fetchFirmwareVersions(deviceID: device.deviceID)
            let variables = try await networking.fetchVariables(deviceID: device.deviceID)

            if device.hasBattery {
                do {
                    let battery = try await networking.fetchBattery(deviceID: device.deviceID)
                    let batterySettings = try await networking.fetchBatterySettings(deviceSN: device.deviceSN)

                    deviceBattery = BatteryResponseMapper.map(battery: battery, settings: batterySettings)
                } catch {
                    deviceBattery = nil
                }
            } else {
                deviceBattery = nil
            }

            return Device(
                plantName: device.plantName,
                deviceID: device.deviceID,
                deviceSN: device.deviceSN,
                hasPV: device.hasPV,
                hasBattery: device.hasBattery,
                battery: deviceBattery,
                deviceType: device.deviceType,
                firmware: firmware,
                variables: variables,
                moduleSN: device.moduleSN
            )
        }
        devices = newDevices
        if selectedDeviceID == nil {
            select(device: devices?.first)
        }
    }

    private func fetchFirmwareVersions(deviceID: String) async throws -> DeviceFirmwareVersion {
        let firmware = try await networking.fetchAddressBook(deviceID: deviceID)

        return DeviceFirmwareVersion(
            master: firmware.softVersion.master,
            slave: firmware.softVersion.slave,
            manager: firmware.softVersion.manager
        )
    }

    public func refreshFirmwareVersions() async throws {
        devices = try await devices?.asyncMap { [weak self] in
            let firmware = try await self?.fetchFirmwareVersions(deviceID: $0.deviceID)
            if firmware != $0.firmware {
                return $0.copy(firmware: firmware)
            } else {
                return $0
            }
        }
    }

    public func logout() {
        config.selectedDeviceID = nil
        config.devices = nil
        config.isDemoUser = false
    }

    public func select(device: Device?) {
        guard let device else { return }

        selectedDeviceID = device.deviceID
    }

    public var firmwareVersions: DeviceFirmwareVersion? {
        currentDevice.value?.firmware
    }

    public var minSOC: Double { Double(currentDevice.value?.battery?.minSOC ?? "0.2") ?? 0.0 }

    public var variables: [RawVariable] {
        currentDevice.value?.variables ?? []
    }

    public var batteryCapacity: String {
        get {
            if let currentDevice = currentDevice.value {
                let override = config.deviceBatteryOverrides[currentDevice.deviceID]

                return override ?? currentDevice.battery?.capacity ?? "0"
            } else {
                return "0"
            }
        }
        set {
            if let currentDevice = currentDevice.value {
                config.deviceBatteryOverrides[currentDevice.deviceID] = newValue
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
        currentDevice.value?.hasBattery ?? false
    }

    public var batteryCapacityW: Int {
        Int(batteryCapacity) ?? 0
    }

    public var selectedDeviceID: String? {
        get { config.selectedDeviceID }
        set {
            config.selectedDeviceID = newValue
            currentDevice.send(devices?.first(where: { $0.deviceID == selectedDeviceID }) ?? devices?.first)
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
            appTheme.send(appTheme.value.copy(
                showColouredLines: config.showColouredLines
            ))
        }
    }

    public var showBatteryTemperature: Bool {
        get { config.showBatteryTemperature }
        set {
            config.showBatteryTemperature = newValue
            appTheme.send(appTheme.value.copy(
                showBatteryTemperature: config.showBatteryTemperature
            ))
        }
    }

    public var showBatteryEstimate: Bool {
        get { config.showBatteryEstimate }
        set {
            config.showBatteryEstimate = newValue
            appTheme.send(appTheme.value.copy(
                showBatteryEstimate: config.showBatteryEstimate
            ))
        }
    }

    public var showUsableBatteryOnly: Bool {
        get { config.showUsableBatteryOnly }
        set {
            config.showUsableBatteryOnly = newValue
            appTheme.send(appTheme.value.copy(
                showUsableBatteryOnly: config.showUsableBatteryOnly
            ))
        }
    }

    public var showTotalYield: Bool {
        get { config.showTotalYield }
        set {
            config.showTotalYield = newValue
            appTheme.send(appTheme.value.copy(
                showTotalYield: config.showTotalYield
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
            appTheme.send(appTheme.value.copy(
                showSunnyBackground: config.showSunnyBackground
            ))
        }
    }

    public var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode {
        get { config.selfSufficiencyEstimateMode }
        set {
            config.selfSufficiencyEstimateMode = newValue
            appTheme.send(appTheme.value.copy(
                selfSufficiencyEstimateMode: config.selfSufficiencyEstimateMode
            ))
        }
    }

    public var decimalPlaces: Int {
        get { config.decimalPlaces }
        set {
            config.decimalPlaces = newValue
            appTheme.send(appTheme.value.copy(
                decimalPlaces: config.decimalPlaces
            ))
        }
    }

    public var showInW: Bool {
        get { config.showInW }
        set {
            config.showInW = newValue
            appTheme.send(appTheme.value.copy(
                showInW: config.showInW
            ))
        }
    }

    public var showEarnings: Bool {
        get { config.showEarnings }
        set {
            config.showEarnings = newValue
            appTheme.send(appTheme.value.copy(
                showEarnings: config.showEarnings
            ))
        }
    }

    public var showInverterTemperature: Bool {
        get { config.showInverterTemperature }
        set {
            config.showInverterTemperature = newValue
            appTheme.send(appTheme.value.copy(
                showInverterTemperature: config.showInverterTemperature
            ))
        }
    }

    public var showInverterTypeNameOnPowerFlow: Bool {
        get { config.showInverterTypeNameOnPowerFlow }
        set {
            config.showInverterTypeNameOnPowerFlow = newValue
            appTheme.send(appTheme.value.copy(
                showInverterTypeNameOnPowerFlow: config.showInverterTypeNameOnPowerFlow
            ))
        }
    }

    public var solarDefinitions: SolarRangeDefinitions {
        get { config.solarDefinitions }
        set {
            config.solarDefinitions = newValue
            appTheme.send(appTheme.value.copy(
                solarDefinitions: config.solarDefinitions
            ))
        }
    }

    public var parameterGroups: [ParameterGroup] {
        get { config.parameterGroups }
        set {
            config.parameterGroups = newValue
            appTheme.send(appTheme.value.copy(
                parameterGroups: config.parameterGroups
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
            appTheme.send(appTheme.value.copy(
                showHomeTotalOnPowerFlow: config.showHomeTotalOnPowerFlow
            ))
        }
    }

    public var showInverterIcon: Bool {
        get { config.showInverterIcon }
        set {
            config.showInverterIcon = newValue
            appTheme.send(appTheme.value.copy(
                showInverterIcon: config.showInverterIcon
            ))
        }
    }

    public var shouldInvertCT2: Bool {
        get { config.shouldInvertCT2 }
        set {
            config.shouldInvertCT2 = newValue
            appTheme.send(appTheme.value.copy(
                shouldInvertCT2: config.shouldInvertCT2
            ))
        }
    }

    public var showInverterPlantName: Bool {
        get { config.showInverterPlantName }
        set {
            config.showInverterPlantName = newValue
            appTheme.send(appTheme.value.copy(
                showInverterPlantName: config.showInverterPlantName
            ))
        }
    }

    public var showGridTotalsOnPowerFlow: Bool {
        get { config.showGridTotalsOnPowerFlow }
        set {
            config.showGridTotalsOnPowerFlow = newValue
            appTheme.send(appTheme.value.copy(
                showGridTotalsOnPowerFlow: config.showGridTotalsOnPowerFlow
            ))
        }
    }

    public var showLastUpdateTimestamp: Bool {
        get { config.showLastUpdateTimestamp }
        set {
            config.showLastUpdateTimestamp = newValue
            appTheme.send(appTheme.value.copy(
                showLastUpdateTimestamp: config.showLastUpdateTimestamp
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
        minSOC = String(Double(settings.minGridSoc) / 100.0)

        return Device.Battery(capacity: batteryCapacity, minSOC: minSOC)
    }
}
